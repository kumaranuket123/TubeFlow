import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkKind { none, wifi, mobile }

abstract class NetworkService {
  Future<NetworkKind> current();
  Stream<NetworkKind> watch();
}

/// Wi-Fi and Ethernet count as unmetered ([NetworkKind.wifi]). Cellular and
/// anything we can't classify (VPN-only, Bluetooth, ...) count as
/// [NetworkKind.mobile], so a Wi-Fi-only rule errs on the side of not using
/// data.
class ConnectivityNetworkService implements NetworkService {
  ConnectivityNetworkService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

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
  Future<NetworkKind> current() async =>
      classify(await _connectivity.checkConnectivity());

  @override
  Stream<NetworkKind> watch() =>
      _connectivity.onConnectivityChanged.map(classify).distinct();
}
