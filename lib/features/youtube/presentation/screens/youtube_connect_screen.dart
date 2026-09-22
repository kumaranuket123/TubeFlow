import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_state.dart';
import '../../domain/entities/youtube_channel.dart';
import '../providers/youtube_auth_providers.dart';

class YoutubeConnectScreen extends ConsumerWidget {
  const YoutubeConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(youtubeAuthControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('TubeFlow')),
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
        const Icon(Icons.smart_display_outlined, size: 64),
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
