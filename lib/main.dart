import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/background/background_scheduler.dart';
import 'core/background/foreground_upload_service.dart';
import 'core/theme/app_theme.dart';
import 'features/youtube/domain/entities/auth_state.dart';
import 'features/youtube/presentation/providers/youtube_auth_providers.dart';
import 'features/youtube/presentation/screens/home_screen.dart';
import 'features/youtube/presentation/screens/youtube_connect_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ForegroundUploadService.init();
  await BackgroundScheduler.init();
  runApp(const ProviderScope(child: TubeFlowApp()));
}

class TubeFlowApp extends ConsumerWidget {
  const TubeFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(youtubeAuthControllerProvider);
    return MaterialApp(
      title: 'TubeFlow',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: auth is AuthConnected ? const HomeScreen() : const YoutubeConnectScreen(),
    );
  }
}
