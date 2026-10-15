import 'package:permission_handler/permission_handler.dart';

/// READ_PHONE_STATE, used only to tell 5G from 4G for the "Also allow 5G"
/// rule. Requested when the user turns that rule on.
class PhoneStatePermissionService {
  Future<bool> isGranted() async => Permission.phone.isGranted;

  /// Requests if needed; true when granted.
  Future<bool> request() async {
    if (await Permission.phone.isGranted) return true;
    return (await Permission.phone.request()).isGranted;
  }

  Future<bool> isPermanentlyDenied() async => Permission.phone.isPermanentlyDenied;

  Future<void> openSettings() => openAppSettings();
}
