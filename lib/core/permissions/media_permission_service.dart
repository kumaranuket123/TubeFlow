import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Video read permission by Android version: READ_MEDIA_VIDEO on 13+,
/// READ_EXTERNAL_STORAGE on 12 and below.
class MediaPermissionService {
  Future<Permission> _permission() async {
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    return sdk >= 33 ? Permission.videos : Permission.storage;
  }

  Future<bool> isGranted() async => (await _permission()).isGranted;

  /// Requests if needed; true when granted.
  Future<bool> request() async {
    final p = await _permission();
    if (await p.isGranted) return true;
    return (await p.request()).isGranted;
  }

  Future<bool> isPermanentlyDenied() async =>
      (await _permission()).isPermanentlyDenied;

  Future<void> openSettings() => openAppSettings();
}
