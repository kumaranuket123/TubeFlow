// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $YoutubeAccountsTable extends YoutubeAccounts
    with TableInfo<$YoutubeAccountsTable, YoutubeAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $YoutubeAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelTitleMeta = const VerificationMeta(
    'channelTitle',
  );
  @override
  late final GeneratedColumn<String> channelTitle = GeneratedColumn<String>(
    'channel_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelThumbnailUrlMeta =
      const VerificationMeta('channelThumbnailUrl');
  @override
  late final GeneratedColumn<String> channelThumbnailUrl =
      GeneratedColumn<String>(
        'channel_thumbnail_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _connectedAtMeta = const VerificationMeta(
    'connectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> connectedAt = GeneratedColumn<DateTime>(
    'connected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    channelId,
    channelTitle,
    channelThumbnailUrl,
    connectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'youtube_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<YoutubeAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('channel_title')) {
      context.handle(
        _channelTitleMeta,
        channelTitle.isAcceptableOrUnknown(
          data['channel_title']!,
          _channelTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_channelTitleMeta);
    }
    if (data.containsKey('channel_thumbnail_url')) {
      context.handle(
        _channelThumbnailUrlMeta,
        channelThumbnailUrl.isAcceptableOrUnknown(
          data['channel_thumbnail_url']!,
          _channelThumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('connected_at')) {
      context.handle(
        _connectedAtMeta,
        connectedAt.isAcceptableOrUnknown(
          data['connected_at']!,
          _connectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  YoutubeAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return YoutubeAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      channelTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_title'],
      )!,
      channelThumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_thumbnail_url'],
      ),
      connectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}connected_at'],
      )!,
    );
  }

  @override
  $YoutubeAccountsTable createAlias(String alias) {
    return $YoutubeAccountsTable(attachedDatabase, alias);
  }
}

class YoutubeAccount extends DataClass implements Insertable<YoutubeAccount> {
  final int id;
  final String channelId;
  final String channelTitle;
  final String? channelThumbnailUrl;
  final DateTime connectedAt;
  const YoutubeAccount({
    required this.id,
    required this.channelId,
    required this.channelTitle,
    this.channelThumbnailUrl,
    required this.connectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['channel_id'] = Variable<String>(channelId);
    map['channel_title'] = Variable<String>(channelTitle);
    if (!nullToAbsent || channelThumbnailUrl != null) {
      map['channel_thumbnail_url'] = Variable<String>(channelThumbnailUrl);
    }
    map['connected_at'] = Variable<DateTime>(connectedAt);
    return map;
  }

  YoutubeAccountsCompanion toCompanion(bool nullToAbsent) {
    return YoutubeAccountsCompanion(
      id: Value(id),
      channelId: Value(channelId),
      channelTitle: Value(channelTitle),
      channelThumbnailUrl: channelThumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(channelThumbnailUrl),
      connectedAt: Value(connectedAt),
    );
  }

  factory YoutubeAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return YoutubeAccount(
      id: serializer.fromJson<int>(json['id']),
      channelId: serializer.fromJson<String>(json['channelId']),
      channelTitle: serializer.fromJson<String>(json['channelTitle']),
      channelThumbnailUrl: serializer.fromJson<String?>(
        json['channelThumbnailUrl'],
      ),
      connectedAt: serializer.fromJson<DateTime>(json['connectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'channelId': serializer.toJson<String>(channelId),
      'channelTitle': serializer.toJson<String>(channelTitle),
      'channelThumbnailUrl': serializer.toJson<String?>(channelThumbnailUrl),
      'connectedAt': serializer.toJson<DateTime>(connectedAt),
    };
  }

  YoutubeAccount copyWith({
    int? id,
    String? channelId,
    String? channelTitle,
    Value<String?> channelThumbnailUrl = const Value.absent(),
    DateTime? connectedAt,
  }) => YoutubeAccount(
    id: id ?? this.id,
    channelId: channelId ?? this.channelId,
    channelTitle: channelTitle ?? this.channelTitle,
    channelThumbnailUrl: channelThumbnailUrl.present
        ? channelThumbnailUrl.value
        : this.channelThumbnailUrl,
    connectedAt: connectedAt ?? this.connectedAt,
  );
  YoutubeAccount copyWithCompanion(YoutubeAccountsCompanion data) {
    return YoutubeAccount(
      id: data.id.present ? data.id.value : this.id,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      channelTitle: data.channelTitle.present
          ? data.channelTitle.value
          : this.channelTitle,
      channelThumbnailUrl: data.channelThumbnailUrl.present
          ? data.channelThumbnailUrl.value
          : this.channelThumbnailUrl,
      connectedAt: data.connectedAt.present
          ? data.connectedAt.value
          : this.connectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('YoutubeAccount(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('channelTitle: $channelTitle, ')
          ..write('channelThumbnailUrl: $channelThumbnailUrl, ')
          ..write('connectedAt: $connectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    channelId,
    channelTitle,
    channelThumbnailUrl,
    connectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is YoutubeAccount &&
          other.id == this.id &&
          other.channelId == this.channelId &&
          other.channelTitle == this.channelTitle &&
          other.channelThumbnailUrl == this.channelThumbnailUrl &&
          other.connectedAt == this.connectedAt);
}

class YoutubeAccountsCompanion extends UpdateCompanion<YoutubeAccount> {
  final Value<int> id;
  final Value<String> channelId;
  final Value<String> channelTitle;
  final Value<String?> channelThumbnailUrl;
  final Value<DateTime> connectedAt;
  const YoutubeAccountsCompanion({
    this.id = const Value.absent(),
    this.channelId = const Value.absent(),
    this.channelTitle = const Value.absent(),
    this.channelThumbnailUrl = const Value.absent(),
    this.connectedAt = const Value.absent(),
  });
  YoutubeAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String channelId,
    required String channelTitle,
    this.channelThumbnailUrl = const Value.absent(),
    required DateTime connectedAt,
  }) : channelId = Value(channelId),
       channelTitle = Value(channelTitle),
       connectedAt = Value(connectedAt);
  static Insertable<YoutubeAccount> custom({
    Expression<int>? id,
    Expression<String>? channelId,
    Expression<String>? channelTitle,
    Expression<String>? channelThumbnailUrl,
    Expression<DateTime>? connectedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (channelId != null) 'channel_id': channelId,
      if (channelTitle != null) 'channel_title': channelTitle,
      if (channelThumbnailUrl != null)
        'channel_thumbnail_url': channelThumbnailUrl,
      if (connectedAt != null) 'connected_at': connectedAt,
    });
  }

  YoutubeAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? channelId,
    Value<String>? channelTitle,
    Value<String?>? channelThumbnailUrl,
    Value<DateTime>? connectedAt,
  }) {
    return YoutubeAccountsCompanion(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      channelTitle: channelTitle ?? this.channelTitle,
      channelThumbnailUrl: channelThumbnailUrl ?? this.channelThumbnailUrl,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (channelTitle.present) {
      map['channel_title'] = Variable<String>(channelTitle.value);
    }
    if (channelThumbnailUrl.present) {
      map['channel_thumbnail_url'] = Variable<String>(
        channelThumbnailUrl.value,
      );
    }
    if (connectedAt.present) {
      map['connected_at'] = Variable<DateTime>(connectedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('YoutubeAccountsCompanion(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('channelTitle: $channelTitle, ')
          ..write('channelThumbnailUrl: $channelThumbnailUrl, ')
          ..write('connectedAt: $connectedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $YoutubeAccountsTable youtubeAccounts = $YoutubeAccountsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [youtubeAccounts];
}

typedef $$YoutubeAccountsTableCreateCompanionBuilder =
    YoutubeAccountsCompanion Function({
      Value<int> id,
      required String channelId,
      required String channelTitle,
      Value<String?> channelThumbnailUrl,
      required DateTime connectedAt,
    });
typedef $$YoutubeAccountsTableUpdateCompanionBuilder =
    YoutubeAccountsCompanion Function({
      Value<int> id,
      Value<String> channelId,
      Value<String> channelTitle,
      Value<String?> channelThumbnailUrl,
      Value<DateTime> connectedAt,
    });

class $$YoutubeAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $YoutubeAccountsTable> {
  $$YoutubeAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelTitle => $composableBuilder(
    column: $table.channelTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelThumbnailUrl => $composableBuilder(
    column: $table.channelThumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$YoutubeAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $YoutubeAccountsTable> {
  $$YoutubeAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelTitle => $composableBuilder(
    column: $table.channelTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelThumbnailUrl => $composableBuilder(
    column: $table.channelThumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$YoutubeAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $YoutubeAccountsTable> {
  $$YoutubeAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get channelTitle => $composableBuilder(
    column: $table.channelTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channelThumbnailUrl => $composableBuilder(
    column: $table.channelThumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => column,
  );
}

class $$YoutubeAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $YoutubeAccountsTable,
          YoutubeAccount,
          $$YoutubeAccountsTableFilterComposer,
          $$YoutubeAccountsTableOrderingComposer,
          $$YoutubeAccountsTableAnnotationComposer,
          $$YoutubeAccountsTableCreateCompanionBuilder,
          $$YoutubeAccountsTableUpdateCompanionBuilder,
          (
            YoutubeAccount,
            BaseReferences<
              _$AppDatabase,
              $YoutubeAccountsTable,
              YoutubeAccount
            >,
          ),
          YoutubeAccount,
          PrefetchHooks Function()
        > {
  $$YoutubeAccountsTableTableManager(
    _$AppDatabase db,
    $YoutubeAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$YoutubeAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$YoutubeAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$YoutubeAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> channelId = const Value.absent(),
                Value<String> channelTitle = const Value.absent(),
                Value<String?> channelThumbnailUrl = const Value.absent(),
                Value<DateTime> connectedAt = const Value.absent(),
              }) => YoutubeAccountsCompanion(
                id: id,
                channelId: channelId,
                channelTitle: channelTitle,
                channelThumbnailUrl: channelThumbnailUrl,
                connectedAt: connectedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String channelId,
                required String channelTitle,
                Value<String?> channelThumbnailUrl = const Value.absent(),
                required DateTime connectedAt,
              }) => YoutubeAccountsCompanion.insert(
                id: id,
                channelId: channelId,
                channelTitle: channelTitle,
                channelThumbnailUrl: channelThumbnailUrl,
                connectedAt: connectedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$YoutubeAccountsTable, YoutubeAccount>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $YoutubeAccountsTable,
                    YoutubeAccount
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$YoutubeAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $YoutubeAccountsTable,
      YoutubeAccount,
      $$YoutubeAccountsTableFilterComposer,
      $$YoutubeAccountsTableOrderingComposer,
      $$YoutubeAccountsTableAnnotationComposer,
      $$YoutubeAccountsTableCreateCompanionBuilder,
      $$YoutubeAccountsTableUpdateCompanionBuilder,
      (
        YoutubeAccount,
        BaseReferences<_$AppDatabase, $YoutubeAccountsTable, YoutubeAccount>,
      ),
      YoutubeAccount,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$YoutubeAccountsTableTableManager get youtubeAccounts =>
      $$YoutubeAccountsTableTableManager(_db, _db.youtubeAccounts);
}
