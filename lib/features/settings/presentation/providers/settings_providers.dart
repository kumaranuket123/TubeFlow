import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(appDatabaseProvider));
});

final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});
