import 'package:drift/drift.dart';

/// Caches display metadata for the connected YouTube channel only — never
/// tokens (those live in [SecureTokenStorage]). Modeled as a single-row
/// table: the app supports exactly one connected account at a time.
class YoutubeAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get channelId => text()();
  TextColumn get channelTitle => text()();
  TextColumn get channelThumbnailUrl => text().nullable()();
  DateTimeColumn get connectedAt => dateTime()();
}
