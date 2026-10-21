import 'package:drift/drift.dart';

@DataClassName('UploadQueueRow')
class UploadQueue extends Table {
  TextColumn get id => text()();
  TextColumn get mediaStoreId => text().nullable()();
  TextColumn get contentUri => text().unique()();
  TextColumn get localPath => text().nullable()();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get dateTaken => dateTime().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get playlistId => text().nullable()();
  TextColumn get status => text()();
  RealColumn get progress => real().withDefault(const Constant(0))();
  TextColumn get youtubeVideoId => text().nullable()();
  TextColumn get sessionUri => text().nullable()();

  /// Visibility the resumable session was created with (fixed for its life).
  TextColumn get privacyStatus => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();

  /// True once the user confirmed deleting the original (Keep original OFF).
  BoolColumn get originalDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
