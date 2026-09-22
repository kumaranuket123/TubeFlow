import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/youtube/presentation/screens/youtube_connect_screen.dart';

void main() {
  runApp(const ProviderScope(child: TubeFlowApp()));
}

class TubeFlowApp extends StatelessWidget {
  const TubeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TubeFlow',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
      // TODO(Phase 10): replace with the real home screen once playlists,
      // queue, and settings exist. Phase 1 only wires up the YouTube
      // connection.
      home: const YoutubeConnectScreen(),
    );
  }
}
