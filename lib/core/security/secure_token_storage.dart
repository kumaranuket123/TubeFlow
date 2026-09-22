import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] for the three pieces of OAuth token state we
/// ever persist. Backed by Android Keystore (EncryptedSharedPreferences) on
/// Android. Tokens never go anywhere else — not Drift, not plain prefs.
class SecureTokenStorage {
  SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'youtube_access_token';
  static const _kRefreshToken = 'youtube_refresh_token';
  static const _kExpiry = 'youtube_access_token_expiry';

  Future<void> saveTokens({
    required String accessToken,
    required String? refreshToken,
    required DateTime? accessTokenExpiry,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _kRefreshToken, value: refreshToken);
    }
    if (accessTokenExpiry != null) {
      await _storage.write(
        key: _kExpiry,
        value: accessTokenExpiry.toIso8601String(),
      );
    }
  }

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);

  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<DateTime?> readAccessTokenExpiry() async {
    final raw = await _storage.read(key: _kExpiry);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kExpiry);
  }
}
