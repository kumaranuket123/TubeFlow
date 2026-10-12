import 'package:battery_plus/battery_plus.dart';

abstract class BatteryService {
  Future<bool> isCharging();
  Stream<bool> watch();
}

/// "Charging" means on external power: charging, full, or plugged in but
/// holding (some phones stop at 80%). Unknown counts as not charging.
class BatteryPlusService implements BatteryService {
  BatteryPlusService([Battery? battery]) : _battery = battery ?? Battery();

  final Battery _battery;

  static bool onPower(BatteryState s) =>
      s == BatteryState.charging ||
      s == BatteryState.full ||
      s == BatteryState.connectedNotCharging;

  @override
  Future<bool> isCharging() async => onPower(await _battery.batteryState);

  @override
  Stream<bool> watch() =>
      _battery.onBatteryStateChanged.map(onPower).distinct();
}
