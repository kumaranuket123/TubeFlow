import 'package:flutter/services.dart';

/// Cellular generation of the current mobile data connection.
enum CellularGen { g5, g4, g3, g2, unknown, permissionDenied }

/// Reads the mobile data generation from Android's TelephonyManager.
/// Needs the READ_PHONE_STATE permission; without it returns
/// [CellularGen.permissionDenied]. Safe to call from any Flutter engine.
class CellularGeneration {
  CellularGeneration._();

  static const _channel = MethodChannel('tubeflow/cellular');

  static Future<CellularGen> read() async {
    try {
      final v = await _channel.invokeMethod<String>('generation');
      return switch (v) {
        '5g' => CellularGen.g5,
        '4g' => CellularGen.g4,
        '3g' => CellularGen.g3,
        '2g' => CellularGen.g2,
        'permission_denied' => CellularGen.permissionDenied,
        _ => CellularGen.unknown,
      };
    } on PlatformException {
      return CellularGen.unknown;
    } on MissingPluginException {
      return CellularGen.unknown;
    }
  }
}
