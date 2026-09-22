import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/app_database.dart';
import '../security/secure_token_storage.dart';

/// Cross-cutting singletons shared by every feature. All `keepAlive: true`
/// since these back long-lived state (an open DB connection, secure storage
/// handles) rather than screen-scoped data.

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final flutterAppAuthProvider = Provider<FlutterAppAuth>((ref) {
  return const FlutterAppAuth();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  // Default AndroidOptions() already uses Keystore-backed AES-GCM storage.
  return const FlutterSecureStorage(aOptions: AndroidOptions());
});

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage(ref.watch(secureStorageProvider));
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
