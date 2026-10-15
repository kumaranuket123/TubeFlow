import 'dart:async';

import 'package:cellular_generation/cellular_generation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// [mobile5g] is mobile data on a 5G connection; [mobile] is any other
/// cellular generation (or 5G that could not be confirmed).
enum NetworkKind { none, wifi, mobile5g, mobile }

abstract class NetworkService {
  Future<NetworkKind> current();
  Stream<NetworkKind> watch();
}

/// Wi-Fi and Ethernet count as unmetered ([NetworkKind.wifi]). Cellular and
/// anything we can't classify (VPN-only, Bluetooth, ...) count as
/// [NetworkKind.mobile], so a Wi-Fi-only rule errs on the side of not using
/// data.
class ConnectivityNetworkService implements NetworkService {
  ConnectivityNetworkService([
    Connectivity? connectivity,
    Future<bool> Function()? is5g,
  ])  : _connectivity = connectivity ?? Connectivity(),
        _is5g = is5g ?? _readIs5g;

  final Connectivity _connectivity;
  final Future<bool> Function() _is5g;

  static Future<bool> _readIs5g() async =>
      await CellularGeneration.read() == CellularGen.g5;

  /// The generation can change without a connectivity event (4G <-> 5G), so
  /// poll while the stream is listened to.
  static const _pollInterval = Duration(seconds: 10);

  static NetworkKind classify(List<ConnectivityResult> results) {
    final active = results.where((r) => r != ConnectivityResult.none);
    if (active.isEmpty) return NetworkKind.none;
    if (active.any((r) =>
        r == ConnectivityResult.wifi || r == ConnectivityResult.ethernet)) {
      return NetworkKind.wifi;
    }
    return NetworkKind.mobile;
  }

  @override
  Future<NetworkKind> current() async {
    final kind = classify(await _connectivity.checkConnectivity());
    if (kind == NetworkKind.mobile && await _is5g()) return NetworkKind.mobile5g;
    return kind;
  }

  @override
  Stream<NetworkKind> watch() {
    late final StreamController<NetworkKind> controller;
    StreamSubscription<List<ConnectivityResult>>? sub;
    Timer? timer;

    Future<void> emit() async {
      try {
        if (!controller.isClosed) controller.add(await current());
      } catch (_) {}
    }

    controller = StreamController<NetworkKind>(
      onListen: () {
        sub = _connectivity.onConnectivityChanged.listen((_) => emit());
        timer = Timer.periodic(_pollInterval, (_) => emit());
      },
      onCancel: () async {
        timer?.cancel();
        await sub?.cancel();
      },
    );
    return controller.stream.distinct();
  }
}
