import '../../../core/battery/battery_service.dart';
import '../../../core/network/network_service.dart';
import '../../settings/domain/entities/app_settings.dart';
import '../../settings/domain/settings_repository.dart';

enum BlockReason {
  noNetwork('Waiting for network'),
  needsWifi('Waiting for Wi-Fi'),
  needsCharger('Waiting for charger');

  const BlockReason(this.message);
  final String message;
}

/// Pure rule evaluation shared by the manager and the UI banner.
/// [network]/[charging] may be null while still unknown (nothing blocks
/// yet). Pass `chargingOnly: false` to evaluate only the network rules.
BlockReason? evaluateConditions({
  required bool wifiOnly,
  required bool chargingOnly,
  required NetworkKind? network,
  required bool? charging,
}) {
  if (network == NetworkKind.none) return BlockReason.noNetwork;
  if (wifiOnly && network != null && network != NetworkKind.wifi) {
    return BlockReason.needsWifi;
  }
  if (chargingOnly && charging == false) return BlockReason.needsCharger;
  return null;
}

BlockReason? evaluateSettings(
  AppSettings s,
  NetworkKind? network,
  bool? charging,
) =>
    evaluateConditions(
      wifiOnly: s.wifiOnly,
      chargingOnly: s.chargingOnly,
      network: network,
      charging: charging,
    );

/// Reads the live network/battery state and the user's rules.
///
/// - [check]: may a NEW upload start? (network + Wi-Fi-only + charging-only)
/// - [checkNetwork]: may an IN-PROGRESS upload continue? Only the network
///   rules apply: leaving Wi-Fi interrupts it (resumable later), but
///   unplugging lets the current video finish; no new one starts.
class UploadConditionChecker {
  UploadConditionChecker({
    required SettingsRepository settings,
    required NetworkService network,
    required BatteryService battery,
  })  : _settings = settings,
        _network = network,
        _battery = battery;

  final SettingsRepository _settings;
  final NetworkService _network;
  final BatteryService _battery;

  Future<BlockReason?> check() async {
    final s = await _settings.get();
    return evaluateSettings(
      s,
      await _network.current(),
      s.chargingOnly ? await _battery.isCharging() : null,
    );
  }

  Future<BlockReason?> checkNetwork() async {
    final s = await _settings.get();
    return evaluateConditions(
      wifiOnly: s.wifiOnly,
      chargingOnly: false,
      network: await _network.current(),
      charging: null,
    );
  }
}
