/// Central place for every YouTube/Google OAuth endpoint and scope used by
/// the app. Kept explicit (rather than resolved via OIDC discovery) so
/// startup doesn't need an extra network round trip just to authenticate.
class YoutubeApiConstants {
  YoutubeApiConstants._();

  /// A single broad scope is requested because both video uploads
  /// (videos.insert) and playlist writes (playlistItems.insert,
  /// playlists.list) require at least `youtube` — there is no narrower scope
  /// that covers both, so splitting scopes buys nothing.
  static const List<String> scopes = <String>[
    'https://www.googleapis.com/auth/youtube',
  ];

  static const String authorizationEndpoint =
      'https://accounts.google.com/o/oauth2/v2/auth';
  static const String tokenEndpoint = 'https://oauth2.googleapis.com/token';
  static const String revokeEndpoint = 'https://oauth2.googleapis.com/revoke';

  /// Default daily Data API quota of a Google Cloud project.
  static const int dailyQuota = 10000;

  /// Units charged by `videos.insert` and by any other write call.
  static const int insertVideoCost = 1600;
  static const int writeCost = 50;

  /// One upload ≈ videos.insert + playlistItems.insert + a few reads.
  static const int uploadTotalCost = insertVideoCost + writeCost + 5;

  static const String apiBaseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String uploadBaseUrl =
      'https://www.googleapis.com/upload/youtube/v3';

  static String get myChannelUrl => '$apiBaseUrl/channels?part=snippet&mine=true';
}
