import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_logo.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/youtube_channel.dart';
import '../providers/youtube_auth_providers.dart';

class YoutubeConnectScreen extends ConsumerWidget {
  const YoutubeConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(youtubeAuthControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const AppBarTitle()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildBody(context, ref, authState),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AuthState state) {
    return switch (state) {
      AuthInitial() || AuthLoading() => const CircularProgressIndicator(),
      AuthDisconnected() => _DisconnectedView(ref: ref),
      AuthConnected(:final channel) => _ConnectedView(ref: ref, channel: channel),
      AuthNoChannel() => _NoChannelView(ref: ref),
      AuthError(:final message) => _ErrorView(ref: ref, message: message),
    };
  }
}

class _DisconnectedView extends StatelessWidget {
  const _DisconnectedView({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(size: 96),
        const SizedBox(height: 16),
        const Text(
          'Connect your YouTube account to let TubeFlow upload your videos automatically.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => ref.read(youtubeAuthControllerProvider.notifier).connect(),
          icon: const Icon(Icons.link),
          label: const Text('Connect YouTube Account'),
        ),
      ],
    );
  }
}

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({required this.ref, required this.channel});

  final WidgetRef ref;
  final YoutubeChannel channel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage:
              channel.thumbnailUrl != null ? NetworkImage(channel.thumbnailUrl!) : null,
          child: channel.thumbnailUrl == null ? const Icon(Icons.person, size: 40) : null,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(channel.title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => ref.read(youtubeAuthControllerProvider.notifier).disconnect(),
          icon: const Icon(Icons.link_off),
          label: const Text('Disconnect'),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.ref, required this.message});

  final WidgetRef ref;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => ref.read(youtubeAuthControllerProvider.notifier).connect(),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}

class _NoChannelView extends StatelessWidget {
  const _NoChannelView({required this.ref});

  final WidgetRef ref;

  static final _createChannelUrl = Uri.parse('https://www.youtube.com/create_channel');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.video_call_outlined, size: 64),
        const SizedBox(height: 16),
        Text(
          'No YouTube channel found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'This Google account does not have a YouTube channel yet. '
          'Create one on YouTube first, then come back to TubeFlow and connect again.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () =>
              launchUrl(_createChannelUrl, mode: LaunchMode.externalApplication),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Create a YouTube channel'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => ref.read(youtubeAuthControllerProvider.notifier).connect(),
          icon: const Icon(Icons.refresh),
          label: const Text("I've created it, connect again"),
        ),
      ],
    );
  }
}
