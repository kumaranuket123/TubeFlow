import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/youtube_api_constants.dart';
import '../di/core_providers.dart';
import '../quota/quota_tracker.dart';

/// Home-screen summary of today's estimated YouTube API credits.
class QuotaCard extends ConsumerWidget {
  const QuotaCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final used = ref.watch(quotaUsedTodayProvider).value ?? 0;
    const total = YoutubeApiConstants.dailyQuota;
    final left = (total - used).clamp(0, total);
    final fraction = left / total;
    final scheme = Theme.of(context).colorScheme;
    final color = fraction > 0.3
        ? scheme.primary
        : fraction > 0.1
            ? Colors.orange
            : scheme.error;
    final uploads = left ~/ YoutubeApiConstants.uploadTotalCost;
    final changes = left ~/ YoutubeApiConstants.writeCost;

    return ListTile(
      leading: const Icon(Icons.bolt_outlined),
      title: Text('API credits: ${_fmt(left)} / ${_fmt(total)} left'),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: fraction, color: color, minHeight: 6),
            const SizedBox(height: 6),
            Text('≈ $uploads upload${uploads == 1 ? '' : 's'} or $changes '
                'playlist / visibility / delete actions left today'),
          ],
        ),
      ),
      trailing: const Icon(Icons.info_outline),
      onTap: () => _showInfo(context, used, left),
    );
  }

  static String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  void _showInfo(BuildContext context, int used, int left) {
    final reset = QuotaTracker.nextReset(DateTime.now());
    final time = TimeOfDay.fromDateTime(reset).format(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('YouTube API credits'),
        content: Text(
          'YouTube gives each app ${_fmt(YoutubeApiConstants.dailyQuota)} credits per day. '
          'Used on this phone today: ${_fmt(used)}.\n\n'
          '• Upload a video: ${_fmt(YoutubeApiConstants.insertVideoCost)} '
          '(+${YoutubeApiConstants.writeCost} to add it to a playlist)\n'
          '• Change visibility, delete, create playlist: ${YoutubeApiConstants.writeCost} each\n'
          '• Loading lists: 1\n\n'
          'Resets daily at midnight Pacific Time (next: $time your time).\n\n'
          'This is an estimate: YouTube does not report the remaining amount, '
          'and the quota is shared by everyone using this app, so the real '
          'number may be lower.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}
