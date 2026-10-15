import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a playlist on YouTube (YouTube app if installed, else the browser).
Future<void> openPlaylistOnYoutube(BuildContext context, String playlistId) async {
  final messenger = ScaffoldMessenger.of(context);
  final uri = Uri.https('www.youtube.com', '/playlist', {'list': playlistId});
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication)
      .catchError((_) => false);
  if (!ok) {
    messenger.showSnackBar(const SnackBar(content: Text('Could not open YouTube.')));
  }
}
