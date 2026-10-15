import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/env.dart';

/// In-app copy of the privacy policy (keep in sync with docs/privacy.html).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget h(String t) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 6),
          child: Text(t, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        );
    Widget p(String t) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(t, style: text.bodyMedium),
        );
    Widget b(String t) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  '),
              Expanded(child: Text(t, style: text.bodyMedium)),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text('Last updated: $kPrivacyPolicyUpdated', style: text.bodySmall),
            const SizedBox(height: 12),
            p('TubeFlow finds videos recorded with your camera and uploads them to '
                'your own YouTube channel as private videos. This policy explains '
                'what data the app accesses and how it is handled.'),
            h('Summary'),
            b('TubeFlow has no server. The developer does not receive, store or see your data.'),
            b('Your videos go only to your own YouTube channel, through Google\'s official YouTube Data API.'),
            b('No ads, no analytics, no third-party trackers.'),
            h('Data the app accesses'),
            b('Google sign-in: OAuth tokens, plus your YouTube channel name, ID and picture to show which account is connected.'),
            b('YouTube data: with the YouTube scope the app uploads videos, lists your playlists, creates playlists you ask for, adds uploaded videos to your chosen playlist, and checks that an upload is private.'),
            b('Videos on your device: with the video permission you grant, the app reads videos in your media library (name, size, date and the file) to detect and upload new recordings. It does not access photos, audio or other files.'),
            b('Network and battery state: only to apply your rules (Wi-Fi only, while charging).'),
            b('Phone state (optional): if you turn on "Also allow 5G", the app asks for the phone-state permission only to read whether your mobile connection is 5G or 4G. It does not read your phone number, calls, contacts or device identifiers, and the value never leaves your device.'),
            b('Notifications: to show upload progress.'),
            h('How data is stored'),
            b('Sign-in tokens are kept on your device in Android\'s encrypted, Keystore-backed storage.'),
            b('The upload queue, settings and channel name are stored in a local database on your device, excluded from cloud backup.'),
            b('Nothing is sent to the developer or to anyone other than Google/YouTube.'),
            h('Deleting your original videos'),
            p('If you turn off "Keep original video", the app can offer to delete a video '
                'from your device after a successful upload. Android always asks you to '
                'confirm; nothing is deleted without your approval.'),
            h('Sharing'),
            p('The app does not sell, share or transfer your data. Videos and playlist '
                'actions are sent to YouTube on your behalf and are then subject to '
                'Google\'s Privacy Policy and the YouTube Terms of Service.'),
            h('Google API Services User Data Policy'),
            p('TubeFlow\'s use and transfer to any other app of information received from '
                'Google APIs adheres to the Google API Services User Data Policy, '
                'including the Limited Use requirements. Google account data is used '
                'only to provide the upload features above, is not used for advertising, '
                'is not sold, and is not read by humans.'),
            h('Disconnecting and deleting your data'),
            b('In the app: open the YouTube screen and tap Disconnect. This revokes access and deletes stored tokens and channel details from your device.'),
            b('From Google: remove TubeFlow\'s access any time at myaccount.google.com/permissions.'),
            b('Uninstalling the app deletes all its local data. Videos already uploaded stay on your YouTube channel until you delete them there.'),
            h('Children'),
            p('The app is not directed at children under 13.'),
            h('Changes'),
            p('If this policy changes, the updated version will be shown here and at the online address, with a new date.'),
            if (kSupportEmail.isNotEmpty) ...[
              h('Contact'),
              p(kSupportEmail),
            ],
            if (kPrivacyPolicyUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => launchUrl(Uri.parse(kPrivacyPolicyUrl),
                      mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open online'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
