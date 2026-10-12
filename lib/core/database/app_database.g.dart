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

class $AppSettingsRowsTable extends AppSettingsRows
    with TableInfo<$AppSettingsRowsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedPlaylistIdMeta =
      const VerificationMeta('selectedPlaylistId');
  @override
  late final GeneratedColumn<String> selectedPlaylistId =
      GeneratedColumn<String>(
        'selected_playlist_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _selectedPlaylistTitleMeta =
      const VerificationMeta('selectedPlaylistTitle');
  @override
  late final GeneratedColumn<String> selectedPlaylistTitle =
      GeneratedColumn<String>(
        'selected_playlist_title',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _autoUploadMeta = const VerificationMeta(
    'autoUpload',
  );
  @override
  late final GeneratedColumn<bool> autoUpload = GeneratedColumn<bool>(
    'auto_upload',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_upload" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wifiOnlyMeta = const VerificationMeta(
    'wifiOnly',
  );
  @override
  late final GeneratedColumn<bool> wifiOnly = GeneratedColumn<bool>(
    'wifi_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("wifi_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _chargingOnlyMeta = const VerificationMeta(
    'chargingOnly',
  );
  @override
  late final GeneratedColumn<bool> chargingOnly = GeneratedColumn<bool>(
    'charging_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("charging_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _keepOriginalMeta = const VerificationMeta(
    'keepOriginal',
  );
  @override
  late final GeneratedColumn<bool> keepOriginal = GeneratedColumn<bool>(
    'keep_original',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("keep_original" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _scanBaselineMeta = const VerificationMeta(
    'scanBaseline',
  );
  @override
  late final GeneratedColumn<DateTime> scanBaseline = GeneratedColumn<DateTime>(
    'scan_baseline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runnerIdMeta = const VerificationMeta(
    'runnerId',
  );
  @override
  late final GeneratedColumn<String> runnerId = GeneratedColumn<String>(
    'runner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runnerLeaseUntilMsMeta =
      const VerificationMeta('runnerLeaseUntilMs');
  @override
  late final GeneratedColumn<int> runnerLeaseUntilMs = GeneratedColumn<int>(
    'runner_lease_until_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    selectedPlaylistId,
    selectedPlaylistTitle,
    autoUpload,
    wifiOnly,
    chargingOnly,
    keepOriginal,
    scanBaseline,
    runnerId,
    runnerLeaseUntilMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('selected_playlist_id')) {
      context.handle(
        _selectedPlaylistIdMeta,
        selectedPlaylistId.isAcceptableOrUnknown(
          data['selected_playlist_id']!,
          _selectedPlaylistIdMeta,
        ),
      );
    }
    if (data.containsKey('selected_playlist_title')) {
      context.handle(
        _selectedPlaylistTitleMeta,
        selectedPlaylistTitle.isAcceptableOrUnknown(
          data['selected_playlist_title']!,
          _selectedPlaylistTitleMeta,
        ),
      );
    }
    if (data.containsKey('auto_upload')) {
      context.handle(
        _autoUploadMeta,
        autoUpload.isAcceptableOrUnknown(data['auto_upload']!, _autoUploadMeta),
      );
    }
    if (data.containsKey('wifi_only')) {
      context.handle(
        _wifiOnlyMeta,
        wifiOnly.isAcceptableOrUnknown(data['wifi_only']!, _wifiOnlyMeta),
      );
    }
    if (data.containsKey('charging_only')) {
      context.handle(
        _chargingOnlyMeta,
        chargingOnly.isAcceptableOrUnknown(
          data['charging_only']!,
          _chargingOnlyMeta,
        ),
      );
    }
    if (data.containsKey('keep_original')) {
      context.handle(
        _keepOriginalMeta,
        keepOriginal.isAcceptableOrUnknown(
          data['keep_original']!,
          _keepOriginalMeta,
        ),
      );
    }
    if (data.containsKey('scan_baseline')) {
      context.handle(
        _scanBaselineMeta,
        scanBaseline.isAcceptableOrUnknown(
          data['scan_baseline']!,
          _scanBaselineMeta,
        ),
      );
    }
    if (data.containsKey('runner_id')) {
      context.handle(
        _runnerIdMeta,
        runnerId.isAcceptableOrUnknown(data['runner_id']!, _runnerIdMeta),
      );
    }
    if (data.containsKey('runner_lease_until_ms')) {
      context.handle(
        _runnerLeaseUntilMsMeta,
        runnerLeaseUntilMs.isAcceptableOrUnknown(
          data['runner_lease_until_ms']!,
          _runnerLeaseUntilMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      selectedPlaylistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_playlist_id'],
      ),
      selectedPlaylistTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_playlist_title'],
      ),
      autoUpload: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_upload'],
      )!,
      wifiOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wifi_only'],
      )!,
      chargingOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}charging_only'],
      )!,
      keepOriginal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_original'],
      )!,
      scanBaseline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scan_baseline'],
      ),
      runnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}runner_id'],
      ),
      runnerLeaseUntilMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runner_lease_until_ms'],
      ),
    );
  }

  @override
  $AppSettingsRowsTable createAlias(String alias) {
    return $AppSettingsRowsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;
  final String? selectedPlaylistId;
  final String? selectedPlaylistTitle;
  final bool autoUpload;
  final bool wifiOnly;
  final bool chargingOnly;
  final bool keepOriginal;

  /// First time scanning was used; only videos added after (baseline - 24h)
  /// are eligible, so the existing gallery is never bulk-queued.
  final DateTime? scanBaseline;

  /// Cross-isolate upload-runner lease (see RunnerLease). Epoch millis.
  final String? runnerId;
  final int? runnerLeaseUntilMs;
  const AppSettingsRow({
    required this.id,
    this.selectedPlaylistId,
    this.selectedPlaylistTitle,
    required this.autoUpload,
    required this.wifiOnly,
    required this.chargingOnly,
    required this.keepOriginal,
    this.scanBaseline,
    this.runnerId,
    this.runnerLeaseUntilMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || selectedPlaylistId != null) {
      map['selected_playlist_id'] = Variable<String>(selectedPlaylistId);
    }
    if (!nullToAbsent || selectedPlaylistTitle != null) {
      map['selected_playlist_title'] = Variable<String>(selectedPlaylistTitle);
    }
    map['auto_upload'] = Variable<bool>(autoUpload);
    map['wifi_only'] = Variable<bool>(wifiOnly);
    map['charging_only'] = Variable<bool>(chargingOnly);
    map['keep_original'] = Variable<bool>(keepOriginal);
    if (!nullToAbsent || scanBaseline != null) {
      map['scan_baseline'] = Variable<DateTime>(scanBaseline);
    }
    if (!nullToAbsent || runnerId != null) {
      map['runner_id'] = Variable<String>(runnerId);
    }
    if (!nullToAbsent || runnerLeaseUntilMs != null) {
      map['runner_lease_until_ms'] = Variable<int>(runnerLeaseUntilMs);
    }
    return map;
  }

  AppSettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsRowsCompanion(
      id: Value(id),
      selectedPlaylistId: selectedPlaylistId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedPlaylistId),
      selectedPlaylistTitle: selectedPlaylistTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedPlaylistTitle),
      autoUpload: Value(autoUpload),
      wifiOnly: Value(wifiOnly),
      chargingOnly: Value(chargingOnly),
      keepOriginal: Value(keepOriginal),
      scanBaseline: scanBaseline == null && nullToAbsent
          ? const Value.absent()
          : Value(scanBaseline),
      runnerId: runnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(runnerId),
      runnerLeaseUntilMs: runnerLeaseUntilMs == null && nullToAbsent
          ? const Value.absent()
          : Value(runnerLeaseUntilMs),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      selectedPlaylistId: serializer.fromJson<String?>(
        json['selectedPlaylistId'],
      ),
      selectedPlaylistTitle: serializer.fromJson<String?>(
        json['selectedPlaylistTitle'],
      ),
      autoUpload: serializer.fromJson<bool>(json['autoUpload']),
      wifiOnly: serializer.fromJson<bool>(json['wifiOnly']),
      chargingOnly: serializer.fromJson<bool>(json['chargingOnly']),
      keepOriginal: serializer.fromJson<bool>(json['keepOriginal']),
      scanBaseline: serializer.fromJson<DateTime?>(json['scanBaseline']),
      runnerId: serializer.fromJson<String?>(json['runnerId']),
      runnerLeaseUntilMs: serializer.fromJson<int?>(json['runnerLeaseUntilMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'selectedPlaylistId': serializer.toJson<String?>(selectedPlaylistId),
      'selectedPlaylistTitle': serializer.toJson<String?>(
        selectedPlaylistTitle,
      ),
      'autoUpload': serializer.toJson<bool>(autoUpload),
      'wifiOnly': serializer.toJson<bool>(wifiOnly),
      'chargingOnly': serializer.toJson<bool>(chargingOnly),
      'keepOriginal': serializer.toJson<bool>(keepOriginal),
      'scanBaseline': serializer.toJson<DateTime?>(scanBaseline),
      'runnerId': serializer.toJson<String?>(runnerId),
      'runnerLeaseUntilMs': serializer.toJson<int?>(runnerLeaseUntilMs),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    Value<String?> selectedPlaylistId = const Value.absent(),
    Value<String?> selectedPlaylistTitle = const Value.absent(),
    bool? autoUpload,
    bool? wifiOnly,
    bool? chargingOnly,
    bool? keepOriginal,
    Value<DateTime?> scanBaseline = const Value.absent(),
    Value<String?> runnerId = const Value.absent(),
    Value<int?> runnerLeaseUntilMs = const Value.absent(),
  }) => AppSettingsRow(
    id: id ?? this.id,
    selectedPlaylistId: selectedPlaylistId.present
        ? selectedPlaylistId.value
        : this.selectedPlaylistId,
    selectedPlaylistTitle: selectedPlaylistTitle.present
        ? selectedPlaylistTitle.value
        : this.selectedPlaylistTitle,
    autoUpload: autoUpload ?? this.autoUpload,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    chargingOnly: chargingOnly ?? this.chargingOnly,
    keepOriginal: keepOriginal ?? this.keepOriginal,
    scanBaseline: scanBaseline.present ? scanBaseline.value : this.scanBaseline,
    runnerId: runnerId.present ? runnerId.value : this.runnerId,
    runnerLeaseUntilMs: runnerLeaseUntilMs.present
        ? runnerLeaseUntilMs.value
        : this.runnerLeaseUntilMs,
  );
  AppSettingsRow copyWithCompanion(AppSettingsRowsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      selectedPlaylistId: data.selectedPlaylistId.present
          ? data.selectedPlaylistId.value
          : this.selectedPlaylistId,
      selectedPlaylistTitle: data.selectedPlaylistTitle.present
          ? data.selectedPlaylistTitle.value
          : this.selectedPlaylistTitle,
      autoUpload: data.autoUpload.present
          ? data.autoUpload.value
          : this.autoUpload,
      wifiOnly: data.wifiOnly.present ? data.wifiOnly.value : this.wifiOnly,
      chargingOnly: data.chargingOnly.present
          ? data.chargingOnly.value
          : this.chargingOnly,
      keepOriginal: data.keepOriginal.present
          ? data.keepOriginal.value
          : this.keepOriginal,
      scanBaseline: data.scanBaseline.present
          ? data.scanBaseline.value
          : this.scanBaseline,
      runnerId: data.runnerId.present ? data.runnerId.value : this.runnerId,
      runnerLeaseUntilMs: data.runnerLeaseUntilMs.present
          ? data.runnerLeaseUntilMs.value
          : this.runnerLeaseUntilMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('selectedPlaylistId: $selectedPlaylistId, ')
          ..write('selectedPlaylistTitle: $selectedPlaylistTitle, ')
          ..write('autoUpload: $autoUpload, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('chargingOnly: $chargingOnly, ')
          ..write('keepOriginal: $keepOriginal, ')
          ..write('scanBaseline: $scanBaseline, ')
          ..write('runnerId: $runnerId, ')
          ..write('runnerLeaseUntilMs: $runnerLeaseUntilMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    selectedPlaylistId,
    selectedPlaylistTitle,
    autoUpload,
    wifiOnly,
    chargingOnly,
    keepOriginal,
    scanBaseline,
    runnerId,
    runnerLeaseUntilMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.selectedPlaylistId == this.selectedPlaylistId &&
          other.selectedPlaylistTitle == this.selectedPlaylistTitle &&
          other.autoUpload == this.autoUpload &&
          other.wifiOnly == this.wifiOnly &&
          other.chargingOnly == this.chargingOnly &&
          other.keepOriginal == this.keepOriginal &&
          other.scanBaseline == this.scanBaseline &&
          other.runnerId == this.runnerId &&
          other.runnerLeaseUntilMs == this.runnerLeaseUntilMs);
}

class AppSettingsRowsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<String?> selectedPlaylistId;
  final Value<String?> selectedPlaylistTitle;
  final Value<bool> autoUpload;
  final Value<bool> wifiOnly;
  final Value<bool> chargingOnly;
  final Value<bool> keepOriginal;
  final Value<DateTime?> scanBaseline;
  final Value<String?> runnerId;
  final Value<int?> runnerLeaseUntilMs;
  const AppSettingsRowsCompanion({
    this.id = const Value.absent(),
    this.selectedPlaylistId = const Value.absent(),
    this.selectedPlaylistTitle = const Value.absent(),
    this.autoUpload = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.chargingOnly = const Value.absent(),
    this.keepOriginal = const Value.absent(),
    this.scanBaseline = const Value.absent(),
    this.runnerId = const Value.absent(),
    this.runnerLeaseUntilMs = const Value.absent(),
  });
  AppSettingsRowsCompanion.insert({
    this.id = const Value.absent(),
    this.selectedPlaylistId = const Value.absent(),
    this.selectedPlaylistTitle = const Value.absent(),
    this.autoUpload = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.chargingOnly = const Value.absent(),
    this.keepOriginal = const Value.absent(),
    this.scanBaseline = const Value.absent(),
    this.runnerId = const Value.absent(),
    this.runnerLeaseUntilMs = const Value.absent(),
  });
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<String>? selectedPlaylistId,
    Expression<String>? selectedPlaylistTitle,
    Expression<bool>? autoUpload,
    Expression<bool>? wifiOnly,
    Expression<bool>? chargingOnly,
    Expression<bool>? keepOriginal,
    Expression<DateTime>? scanBaseline,
    Expression<String>? runnerId,
    Expression<int>? runnerLeaseUntilMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (selectedPlaylistId != null)
        'selected_playlist_id': selectedPlaylistId,
      if (selectedPlaylistTitle != null)
        'selected_playlist_title': selectedPlaylistTitle,
      if (autoUpload != null) 'auto_upload': autoUpload,
      if (wifiOnly != null) 'wifi_only': wifiOnly,
      if (chargingOnly != null) 'charging_only': chargingOnly,
      if (keepOriginal != null) 'keep_original': keepOriginal,
      if (scanBaseline != null) 'scan_baseline': scanBaseline,
      if (runnerId != null) 'runner_id': runnerId,
      if (runnerLeaseUntilMs != null)
        'runner_lease_until_ms': runnerLeaseUntilMs,
    });
  }

  AppSettingsRowsCompanion copyWith({
    Value<int>? id,
    Value<String?>? selectedPlaylistId,
    Value<String?>? selectedPlaylistTitle,
    Value<bool>? autoUpload,
    Value<bool>? wifiOnly,
    Value<bool>? chargingOnly,
    Value<bool>? keepOriginal,
    Value<DateTime?>? scanBaseline,
    Value<String?>? runnerId,
    Value<int?>? runnerLeaseUntilMs,
  }) {
    return AppSettingsRowsCompanion(
      id: id ?? this.id,
      selectedPlaylistId: selectedPlaylistId ?? this.selectedPlaylistId,
      selectedPlaylistTitle:
          selectedPlaylistTitle ?? this.selectedPlaylistTitle,
      autoUpload: autoUpload ?? this.autoUpload,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      chargingOnly: chargingOnly ?? this.chargingOnly,
      keepOriginal: keepOriginal ?? this.keepOriginal,
      scanBaseline: scanBaseline ?? this.scanBaseline,
      runnerId: runnerId ?? this.runnerId,
      runnerLeaseUntilMs: runnerLeaseUntilMs ?? this.runnerLeaseUntilMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (selectedPlaylistId.present) {
      map['selected_playlist_id'] = Variable<String>(selectedPlaylistId.value);
    }
    if (selectedPlaylistTitle.present) {
      map['selected_playlist_title'] = Variable<String>(
        selectedPlaylistTitle.value,
      );
    }
    if (autoUpload.present) {
      map['auto_upload'] = Variable<bool>(autoUpload.value);
    }
    if (wifiOnly.present) {
      map['wifi_only'] = Variable<bool>(wifiOnly.value);
    }
    if (chargingOnly.present) {
      map['charging_only'] = Variable<bool>(chargingOnly.value);
    }
    if (keepOriginal.present) {
      map['keep_original'] = Variable<bool>(keepOriginal.value);
    }
    if (scanBaseline.present) {
      map['scan_baseline'] = Variable<DateTime>(scanBaseline.value);
    }
    if (runnerId.present) {
      map['runner_id'] = Variable<String>(runnerId.value);
    }
    if (runnerLeaseUntilMs.present) {
      map['runner_lease_until_ms'] = Variable<int>(runnerLeaseUntilMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRowsCompanion(')
          ..write('id: $id, ')
          ..write('selectedPlaylistId: $selectedPlaylistId, ')
          ..write('selectedPlaylistTitle: $selectedPlaylistTitle, ')
          ..write('autoUpload: $autoUpload, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('chargingOnly: $chargingOnly, ')
          ..write('keepOriginal: $keepOriginal, ')
          ..write('scanBaseline: $scanBaseline, ')
          ..write('runnerId: $runnerId, ')
          ..write('runnerLeaseUntilMs: $runnerLeaseUntilMs')
          ..write(')'))
        .toString();
  }
}

class $UploadQueueTable extends UploadQueue
    with TableInfo<$UploadQueueTable, UploadQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UploadQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaStoreIdMeta = const VerificationMeta(
    'mediaStoreId',
  );
  @override
  late final GeneratedColumn<String> mediaStoreId = GeneratedColumn<String>(
    'media_store_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentUriMeta = const VerificationMeta(
    'contentUri',
  );
  @override
  late final GeneratedColumn<String> contentUri = GeneratedColumn<String>(
    'content_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateTakenMeta = const VerificationMeta(
    'dateTaken',
  );
  @override
  late final GeneratedColumn<DateTime> dateTaken = GeneratedColumn<DateTime>(
    'date_taken',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _youtubeVideoIdMeta = const VerificationMeta(
    'youtubeVideoId',
  );
  @override
  late final GeneratedColumn<String> youtubeVideoId = GeneratedColumn<String>(
    'youtube_video_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionUriMeta = const VerificationMeta(
    'sessionUri',
  );
  @override
  late final GeneratedColumn<String> sessionUri = GeneratedColumn<String>(
    'session_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalDeletedMeta = const VerificationMeta(
    'originalDeleted',
  );
  @override
  late final GeneratedColumn<bool> originalDeleted = GeneratedColumn<bool>(
    'original_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("original_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaStoreId,
    contentUri,
    localPath,
    fileName,
    fileSize,
    dateTaken,
    title,
    description,
    playlistId,
    status,
    progress,
    youtubeVideoId,
    sessionUri,
    createdAt,
    updatedAt,
    retryCount,
    errorMessage,
    originalDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'upload_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<UploadQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_store_id')) {
      context.handle(
        _mediaStoreIdMeta,
        mediaStoreId.isAcceptableOrUnknown(
          data['media_store_id']!,
          _mediaStoreIdMeta,
        ),
      );
    }
    if (data.containsKey('content_uri')) {
      context.handle(
        _contentUriMeta,
        contentUri.isAcceptableOrUnknown(data['content_uri']!, _contentUriMeta),
      );
    } else if (isInserting) {
      context.missing(_contentUriMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('date_taken')) {
      context.handle(
        _dateTakenMeta,
        dateTaken.isAcceptableOrUnknown(data['date_taken']!, _dateTakenMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('youtube_video_id')) {
      context.handle(
        _youtubeVideoIdMeta,
        youtubeVideoId.isAcceptableOrUnknown(
          data['youtube_video_id']!,
          _youtubeVideoIdMeta,
        ),
      );
    }
    if (data.containsKey('session_uri')) {
      context.handle(
        _sessionUriMeta,
        sessionUri.isAcceptableOrUnknown(data['session_uri']!, _sessionUriMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('original_deleted')) {
      context.handle(
        _originalDeletedMeta,
        originalDeleted.isAcceptableOrUnknown(
          data['original_deleted']!,
          _originalDeletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UploadQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UploadQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaStoreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_store_id'],
      ),
      contentUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_uri'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      dateTaken: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_taken'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      youtubeVideoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}youtube_video_id'],
      ),
      sessionUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uri'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      originalDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}original_deleted'],
      )!,
    );
  }

  @override
  $UploadQueueTable createAlias(String alias) {
    return $UploadQueueTable(attachedDatabase, alias);
  }
}

class UploadQueueRow extends DataClass implements Insertable<UploadQueueRow> {
  final String id;
  final String? mediaStoreId;
  final String contentUri;
  final String? localPath;
  final String fileName;
  final int fileSize;
  final DateTime? dateTaken;
  final String title;
  final String description;
  final String? playlistId;
  final String status;
  final double progress;
  final String? youtubeVideoId;
  final String? sessionUri;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int retryCount;
  final String? errorMessage;

  /// True once the user confirmed deleting the original (Keep original OFF).
  final bool originalDeleted;
  const UploadQueueRow({
    required this.id,
    this.mediaStoreId,
    required this.contentUri,
    this.localPath,
    required this.fileName,
    required this.fileSize,
    this.dateTaken,
    required this.title,
    required this.description,
    this.playlistId,
    required this.status,
    required this.progress,
    this.youtubeVideoId,
    this.sessionUri,
    required this.createdAt,
    required this.updatedAt,
    required this.retryCount,
    this.errorMessage,
    required this.originalDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || mediaStoreId != null) {
      map['media_store_id'] = Variable<String>(mediaStoreId);
    }
    map['content_uri'] = Variable<String>(contentUri);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['file_name'] = Variable<String>(fileName);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || dateTaken != null) {
      map['date_taken'] = Variable<DateTime>(dateTaken);
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || playlistId != null) {
      map['playlist_id'] = Variable<String>(playlistId);
    }
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || youtubeVideoId != null) {
      map['youtube_video_id'] = Variable<String>(youtubeVideoId);
    }
    if (!nullToAbsent || sessionUri != null) {
      map['session_uri'] = Variable<String>(sessionUri);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['original_deleted'] = Variable<bool>(originalDeleted);
    return map;
  }

  UploadQueueCompanion toCompanion(bool nullToAbsent) {
    return UploadQueueCompanion(
      id: Value(id),
      mediaStoreId: mediaStoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaStoreId),
      contentUri: Value(contentUri),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      fileName: Value(fileName),
      fileSize: Value(fileSize),
      dateTaken: dateTaken == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTaken),
      title: Value(title),
      description: Value(description),
      playlistId: playlistId == null && nullToAbsent
          ? const Value.absent()
          : Value(playlistId),
      status: Value(status),
      progress: Value(progress),
      youtubeVideoId: youtubeVideoId == null && nullToAbsent
          ? const Value.absent()
          : Value(youtubeVideoId),
      sessionUri: sessionUri == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionUri),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      retryCount: Value(retryCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      originalDeleted: Value(originalDeleted),
    );
  }

  factory UploadQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UploadQueueRow(
      id: serializer.fromJson<String>(json['id']),
      mediaStoreId: serializer.fromJson<String?>(json['mediaStoreId']),
      contentUri: serializer.fromJson<String>(json['contentUri']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      dateTaken: serializer.fromJson<DateTime?>(json['dateTaken']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      playlistId: serializer.fromJson<String?>(json['playlistId']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      youtubeVideoId: serializer.fromJson<String?>(json['youtubeVideoId']),
      sessionUri: serializer.fromJson<String?>(json['sessionUri']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      originalDeleted: serializer.fromJson<bool>(json['originalDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaStoreId': serializer.toJson<String?>(mediaStoreId),
      'contentUri': serializer.toJson<String>(contentUri),
      'localPath': serializer.toJson<String?>(localPath),
      'fileName': serializer.toJson<String>(fileName),
      'fileSize': serializer.toJson<int>(fileSize),
      'dateTaken': serializer.toJson<DateTime?>(dateTaken),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'playlistId': serializer.toJson<String?>(playlistId),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<double>(progress),
      'youtubeVideoId': serializer.toJson<String?>(youtubeVideoId),
      'sessionUri': serializer.toJson<String?>(sessionUri),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'originalDeleted': serializer.toJson<bool>(originalDeleted),
    };
  }

  UploadQueueRow copyWith({
    String? id,
    Value<String?> mediaStoreId = const Value.absent(),
    String? contentUri,
    Value<String?> localPath = const Value.absent(),
    String? fileName,
    int? fileSize,
    Value<DateTime?> dateTaken = const Value.absent(),
    String? title,
    String? description,
    Value<String?> playlistId = const Value.absent(),
    String? status,
    double? progress,
    Value<String?> youtubeVideoId = const Value.absent(),
    Value<String?> sessionUri = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? retryCount,
    Value<String?> errorMessage = const Value.absent(),
    bool? originalDeleted,
  }) => UploadQueueRow(
    id: id ?? this.id,
    mediaStoreId: mediaStoreId.present ? mediaStoreId.value : this.mediaStoreId,
    contentUri: contentUri ?? this.contentUri,
    localPath: localPath.present ? localPath.value : this.localPath,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize ?? this.fileSize,
    dateTaken: dateTaken.present ? dateTaken.value : this.dateTaken,
    title: title ?? this.title,
    description: description ?? this.description,
    playlistId: playlistId.present ? playlistId.value : this.playlistId,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    youtubeVideoId: youtubeVideoId.present
        ? youtubeVideoId.value
        : this.youtubeVideoId,
    sessionUri: sessionUri.present ? sessionUri.value : this.sessionUri,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    retryCount: retryCount ?? this.retryCount,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    originalDeleted: originalDeleted ?? this.originalDeleted,
  );
  UploadQueueRow copyWithCompanion(UploadQueueCompanion data) {
    return UploadQueueRow(
      id: data.id.present ? data.id.value : this.id,
      mediaStoreId: data.mediaStoreId.present
          ? data.mediaStoreId.value
          : this.mediaStoreId,
      contentUri: data.contentUri.present
          ? data.contentUri.value
          : this.contentUri,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      dateTaken: data.dateTaken.present ? data.dateTaken.value : this.dateTaken,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      youtubeVideoId: data.youtubeVideoId.present
          ? data.youtubeVideoId.value
          : this.youtubeVideoId,
      sessionUri: data.sessionUri.present
          ? data.sessionUri.value
          : this.sessionUri,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      originalDeleted: data.originalDeleted.present
          ? data.originalDeleted.value
          : this.originalDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UploadQueueRow(')
          ..write('id: $id, ')
          ..write('mediaStoreId: $mediaStoreId, ')
          ..write('contentUri: $contentUri, ')
          ..write('localPath: $localPath, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('dateTaken: $dateTaken, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('playlistId: $playlistId, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('youtubeVideoId: $youtubeVideoId, ')
          ..write('sessionUri: $sessionUri, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('originalDeleted: $originalDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaStoreId,
    contentUri,
    localPath,
    fileName,
    fileSize,
    dateTaken,
    title,
    description,
    playlistId,
    status,
    progress,
    youtubeVideoId,
    sessionUri,
    createdAt,
    updatedAt,
    retryCount,
    errorMessage,
    originalDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UploadQueueRow &&
          other.id == this.id &&
          other.mediaStoreId == this.mediaStoreId &&
          other.contentUri == this.contentUri &&
          other.localPath == this.localPath &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.dateTaken == this.dateTaken &&
          other.title == this.title &&
          other.description == this.description &&
          other.playlistId == this.playlistId &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.youtubeVideoId == this.youtubeVideoId &&
          other.sessionUri == this.sessionUri &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.retryCount == this.retryCount &&
          other.errorMessage == this.errorMessage &&
          other.originalDeleted == this.originalDeleted);
}

class UploadQueueCompanion extends UpdateCompanion<UploadQueueRow> {
  final Value<String> id;
  final Value<String?> mediaStoreId;
  final Value<String> contentUri;
  final Value<String?> localPath;
  final Value<String> fileName;
  final Value<int> fileSize;
  final Value<DateTime?> dateTaken;
  final Value<String> title;
  final Value<String> description;
  final Value<String?> playlistId;
  final Value<String> status;
  final Value<double> progress;
  final Value<String?> youtubeVideoId;
  final Value<String?> sessionUri;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> retryCount;
  final Value<String?> errorMessage;
  final Value<bool> originalDeleted;
  final Value<int> rowid;
  const UploadQueueCompanion({
    this.id = const Value.absent(),
    this.mediaStoreId = const Value.absent(),
    this.contentUri = const Value.absent(),
    this.localPath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.dateTaken = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.youtubeVideoId = const Value.absent(),
    this.sessionUri = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.originalDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UploadQueueCompanion.insert({
    required String id,
    this.mediaStoreId = const Value.absent(),
    required String contentUri,
    this.localPath = const Value.absent(),
    required String fileName,
    required int fileSize,
    this.dateTaken = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.playlistId = const Value.absent(),
    required String status,
    this.progress = const Value.absent(),
    this.youtubeVideoId = const Value.absent(),
    this.sessionUri = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.originalDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contentUri = Value(contentUri),
       fileName = Value(fileName),
       fileSize = Value(fileSize),
       title = Value(title),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UploadQueueRow> custom({
    Expression<String>? id,
    Expression<String>? mediaStoreId,
    Expression<String>? contentUri,
    Expression<String>? localPath,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<DateTime>? dateTaken,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? playlistId,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<String>? youtubeVideoId,
    Expression<String>? sessionUri,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? retryCount,
    Expression<String>? errorMessage,
    Expression<bool>? originalDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaStoreId != null) 'media_store_id': mediaStoreId,
      if (contentUri != null) 'content_uri': contentUri,
      if (localPath != null) 'local_path': localPath,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (dateTaken != null) 'date_taken': dateTaken,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (playlistId != null) 'playlist_id': playlistId,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (youtubeVideoId != null) 'youtube_video_id': youtubeVideoId,
      if (sessionUri != null) 'session_uri': sessionUri,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (originalDeleted != null) 'original_deleted': originalDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UploadQueueCompanion copyWith({
    Value<String>? id,
    Value<String?>? mediaStoreId,
    Value<String>? contentUri,
    Value<String?>? localPath,
    Value<String>? fileName,
    Value<int>? fileSize,
    Value<DateTime?>? dateTaken,
    Value<String>? title,
    Value<String>? description,
    Value<String?>? playlistId,
    Value<String>? status,
    Value<double>? progress,
    Value<String?>? youtubeVideoId,
    Value<String?>? sessionUri,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? retryCount,
    Value<String?>? errorMessage,
    Value<bool>? originalDeleted,
    Value<int>? rowid,
  }) {
    return UploadQueueCompanion(
      id: id ?? this.id,
      mediaStoreId: mediaStoreId ?? this.mediaStoreId,
      contentUri: contentUri ?? this.contentUri,
      localPath: localPath ?? this.localPath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      dateTaken: dateTaken ?? this.dateTaken,
      title: title ?? this.title,
      description: description ?? this.description,
      playlistId: playlistId ?? this.playlistId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      sessionUri: sessionUri ?? this.sessionUri,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      originalDeleted: originalDeleted ?? this.originalDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaStoreId.present) {
      map['media_store_id'] = Variable<String>(mediaStoreId.value);
    }
    if (contentUri.present) {
      map['content_uri'] = Variable<String>(contentUri.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (dateTaken.present) {
      map['date_taken'] = Variable<DateTime>(dateTaken.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (youtubeVideoId.present) {
      map['youtube_video_id'] = Variable<String>(youtubeVideoId.value);
    }
    if (sessionUri.present) {
      map['session_uri'] = Variable<String>(sessionUri.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (originalDeleted.present) {
      map['original_deleted'] = Variable<bool>(originalDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UploadQueueCompanion(')
          ..write('id: $id, ')
          ..write('mediaStoreId: $mediaStoreId, ')
          ..write('contentUri: $contentUri, ')
          ..write('localPath: $localPath, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('dateTaken: $dateTaken, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('playlistId: $playlistId, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('youtubeVideoId: $youtubeVideoId, ')
          ..write('sessionUri: $sessionUri, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('originalDeleted: $originalDeleted, ')
          ..write('rowid: $rowid')
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
  late final $AppSettingsRowsTable appSettingsRows = $AppSettingsRowsTable(
    this,
  );
  late final $UploadQueueTable uploadQueue = $UploadQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    youtubeAccounts,
    appSettingsRows,
    uploadQueue,
  ];
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
typedef $$AppSettingsRowsTableCreateCompanionBuilder =
    AppSettingsRowsCompanion Function({
      Value<int> id,
      Value<String?> selectedPlaylistId,
      Value<String?> selectedPlaylistTitle,
      Value<bool> autoUpload,
      Value<bool> wifiOnly,
      Value<bool> chargingOnly,
      Value<bool> keepOriginal,
      Value<DateTime?> scanBaseline,
      Value<String?> runnerId,
      Value<int?> runnerLeaseUntilMs,
    });
typedef $$AppSettingsRowsTableUpdateCompanionBuilder =
    AppSettingsRowsCompanion Function({
      Value<int> id,
      Value<String?> selectedPlaylistId,
      Value<String?> selectedPlaylistTitle,
      Value<bool> autoUpload,
      Value<bool> wifiOnly,
      Value<bool> chargingOnly,
      Value<bool> keepOriginal,
      Value<DateTime?> scanBaseline,
      Value<String?> runnerId,
      Value<int?> runnerLeaseUntilMs,
    });

class $$AppSettingsRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsRowsTable> {
  $$AppSettingsRowsTableFilterComposer({
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

  ColumnFilters<String> get selectedPlaylistId => $composableBuilder(
    column: $table.selectedPlaylistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedPlaylistTitle => $composableBuilder(
    column: $table.selectedPlaylistTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoUpload => $composableBuilder(
    column: $table.autoUpload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get chargingOnly => $composableBuilder(
    column: $table.chargingOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get keepOriginal => $composableBuilder(
    column: $table.keepOriginal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scanBaseline => $composableBuilder(
    column: $table.scanBaseline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runnerId => $composableBuilder(
    column: $table.runnerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runnerLeaseUntilMs => $composableBuilder(
    column: $table.runnerLeaseUntilMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsRowsTable> {
  $$AppSettingsRowsTableOrderingComposer({
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

  ColumnOrderings<String> get selectedPlaylistId => $composableBuilder(
    column: $table.selectedPlaylistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedPlaylistTitle => $composableBuilder(
    column: $table.selectedPlaylistTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoUpload => $composableBuilder(
    column: $table.autoUpload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get chargingOnly => $composableBuilder(
    column: $table.chargingOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get keepOriginal => $composableBuilder(
    column: $table.keepOriginal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scanBaseline => $composableBuilder(
    column: $table.scanBaseline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runnerId => $composableBuilder(
    column: $table.runnerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runnerLeaseUntilMs => $composableBuilder(
    column: $table.runnerLeaseUntilMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsRowsTable> {
  $$AppSettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get selectedPlaylistId => $composableBuilder(
    column: $table.selectedPlaylistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedPlaylistTitle => $composableBuilder(
    column: $table.selectedPlaylistTitle,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoUpload => $composableBuilder(
    column: $table.autoUpload,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wifiOnly =>
      $composableBuilder(column: $table.wifiOnly, builder: (column) => column);

  GeneratedColumn<bool> get chargingOnly => $composableBuilder(
    column: $table.chargingOnly,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get keepOriginal => $composableBuilder(
    column: $table.keepOriginal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scanBaseline => $composableBuilder(
    column: $table.scanBaseline,
    builder: (column) => column,
  );

  GeneratedColumn<String> get runnerId =>
      $composableBuilder(column: $table.runnerId, builder: (column) => column);

  GeneratedColumn<int> get runnerLeaseUntilMs => $composableBuilder(
    column: $table.runnerLeaseUntilMs,
    builder: (column) => column,
  );
}

class $$AppSettingsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsRowsTable,
          AppSettingsRow,
          $$AppSettingsRowsTableFilterComposer,
          $$AppSettingsRowsTableOrderingComposer,
          $$AppSettingsRowsTableAnnotationComposer,
          $$AppSettingsRowsTableCreateCompanionBuilder,
          $$AppSettingsRowsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsRowsTable,
              AppSettingsRow
            >,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsRowsTableTableManager(
    _$AppDatabase db,
    $AppSettingsRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> selectedPlaylistId = const Value.absent(),
                Value<String?> selectedPlaylistTitle = const Value.absent(),
                Value<bool> autoUpload = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<bool> chargingOnly = const Value.absent(),
                Value<bool> keepOriginal = const Value.absent(),
                Value<DateTime?> scanBaseline = const Value.absent(),
                Value<String?> runnerId = const Value.absent(),
                Value<int?> runnerLeaseUntilMs = const Value.absent(),
              }) => AppSettingsRowsCompanion(
                id: id,
                selectedPlaylistId: selectedPlaylistId,
                selectedPlaylistTitle: selectedPlaylistTitle,
                autoUpload: autoUpload,
                wifiOnly: wifiOnly,
                chargingOnly: chargingOnly,
                keepOriginal: keepOriginal,
                scanBaseline: scanBaseline,
                runnerId: runnerId,
                runnerLeaseUntilMs: runnerLeaseUntilMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> selectedPlaylistId = const Value.absent(),
                Value<String?> selectedPlaylistTitle = const Value.absent(),
                Value<bool> autoUpload = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<bool> chargingOnly = const Value.absent(),
                Value<bool> keepOriginal = const Value.absent(),
                Value<DateTime?> scanBaseline = const Value.absent(),
                Value<String?> runnerId = const Value.absent(),
                Value<int?> runnerLeaseUntilMs = const Value.absent(),
              }) => AppSettingsRowsCompanion.insert(
                id: id,
                selectedPlaylistId: selectedPlaylistId,
                selectedPlaylistTitle: selectedPlaylistTitle,
                autoUpload: autoUpload,
                wifiOnly: wifiOnly,
                chargingOnly: chargingOnly,
                keepOriginal: keepOriginal,
                scanBaseline: scanBaseline,
                runnerId: runnerId,
                runnerLeaseUntilMs: runnerLeaseUntilMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsRowsTable, AppSettingsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsRowsTable,
                    AppSettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsRowsTable,
      AppSettingsRow,
      $$AppSettingsRowsTableFilterComposer,
      $$AppSettingsRowsTableOrderingComposer,
      $$AppSettingsRowsTableAnnotationComposer,
      $$AppSettingsRowsTableCreateCompanionBuilder,
      $$AppSettingsRowsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsRowsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$UploadQueueTableCreateCompanionBuilder =
    UploadQueueCompanion Function({
      required String id,
      Value<String?> mediaStoreId,
      required String contentUri,
      Value<String?> localPath,
      required String fileName,
      required int fileSize,
      Value<DateTime?> dateTaken,
      required String title,
      Value<String> description,
      Value<String?> playlistId,
      required String status,
      Value<double> progress,
      Value<String?> youtubeVideoId,
      Value<String?> sessionUri,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> retryCount,
      Value<String?> errorMessage,
      Value<bool> originalDeleted,
      Value<int> rowid,
    });
typedef $$UploadQueueTableUpdateCompanionBuilder =
    UploadQueueCompanion Function({
      Value<String> id,
      Value<String?> mediaStoreId,
      Value<String> contentUri,
      Value<String?> localPath,
      Value<String> fileName,
      Value<int> fileSize,
      Value<DateTime?> dateTaken,
      Value<String> title,
      Value<String> description,
      Value<String?> playlistId,
      Value<String> status,
      Value<double> progress,
      Value<String?> youtubeVideoId,
      Value<String?> sessionUri,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> retryCount,
      Value<String?> errorMessage,
      Value<bool> originalDeleted,
      Value<int> rowid,
    });

class $$UploadQueueTableFilterComposer
    extends Composer<_$AppDatabase, $UploadQueueTable> {
  $$UploadQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaStoreId => $composableBuilder(
    column: $table.mediaStoreId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentUri => $composableBuilder(
    column: $table.contentUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateTaken => $composableBuilder(
    column: $table.dateTaken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get youtubeVideoId => $composableBuilder(
    column: $table.youtubeVideoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionUri => $composableBuilder(
    column: $table.sessionUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get originalDeleted => $composableBuilder(
    column: $table.originalDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UploadQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $UploadQueueTable> {
  $$UploadQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaStoreId => $composableBuilder(
    column: $table.mediaStoreId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentUri => $composableBuilder(
    column: $table.contentUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateTaken => $composableBuilder(
    column: $table.dateTaken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get youtubeVideoId => $composableBuilder(
    column: $table.youtubeVideoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionUri => $composableBuilder(
    column: $table.sessionUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get originalDeleted => $composableBuilder(
    column: $table.originalDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UploadQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $UploadQueueTable> {
  $$UploadQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mediaStoreId => $composableBuilder(
    column: $table.mediaStoreId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentUri => $composableBuilder(
    column: $table.contentUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get dateTaken =>
      $composableBuilder(column: $table.dateTaken, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get youtubeVideoId => $composableBuilder(
    column: $table.youtubeVideoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionUri => $composableBuilder(
    column: $table.sessionUri,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get originalDeleted => $composableBuilder(
    column: $table.originalDeleted,
    builder: (column) => column,
  );
}

class $$UploadQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UploadQueueTable,
          UploadQueueRow,
          $$UploadQueueTableFilterComposer,
          $$UploadQueueTableOrderingComposer,
          $$UploadQueueTableAnnotationComposer,
          $$UploadQueueTableCreateCompanionBuilder,
          $$UploadQueueTableUpdateCompanionBuilder,
          (
            UploadQueueRow,
            BaseReferences<_$AppDatabase, $UploadQueueTable, UploadQueueRow>,
          ),
          UploadQueueRow,
          PrefetchHooks Function()
        > {
  $$UploadQueueTableTableManager(_$AppDatabase db, $UploadQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UploadQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UploadQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UploadQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> mediaStoreId = const Value.absent(),
                Value<String> contentUri = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<DateTime?> dateTaken = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> playlistId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> youtubeVideoId = const Value.absent(),
                Value<String?> sessionUri = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<bool> originalDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UploadQueueCompanion(
                id: id,
                mediaStoreId: mediaStoreId,
                contentUri: contentUri,
                localPath: localPath,
                fileName: fileName,
                fileSize: fileSize,
                dateTaken: dateTaken,
                title: title,
                description: description,
                playlistId: playlistId,
                status: status,
                progress: progress,
                youtubeVideoId: youtubeVideoId,
                sessionUri: sessionUri,
                createdAt: createdAt,
                updatedAt: updatedAt,
                retryCount: retryCount,
                errorMessage: errorMessage,
                originalDeleted: originalDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> mediaStoreId = const Value.absent(),
                required String contentUri,
                Value<String?> localPath = const Value.absent(),
                required String fileName,
                required int fileSize,
                Value<DateTime?> dateTaken = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                Value<String?> playlistId = const Value.absent(),
                required String status,
                Value<double> progress = const Value.absent(),
                Value<String?> youtubeVideoId = const Value.absent(),
                Value<String?> sessionUri = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> retryCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<bool> originalDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UploadQueueCompanion.insert(
                id: id,
                mediaStoreId: mediaStoreId,
                contentUri: contentUri,
                localPath: localPath,
                fileName: fileName,
                fileSize: fileSize,
                dateTaken: dateTaken,
                title: title,
                description: description,
                playlistId: playlistId,
                status: status,
                progress: progress,
                youtubeVideoId: youtubeVideoId,
                sessionUri: sessionUri,
                createdAt: createdAt,
                updatedAt: updatedAt,
                retryCount: retryCount,
                errorMessage: errorMessage,
                originalDeleted: originalDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UploadQueueTable, UploadQueueRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UploadQueueTable,
                    UploadQueueRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UploadQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UploadQueueTable,
      UploadQueueRow,
      $$UploadQueueTableFilterComposer,
      $$UploadQueueTableOrderingComposer,
      $$UploadQueueTableAnnotationComposer,
      $$UploadQueueTableCreateCompanionBuilder,
      $$UploadQueueTableUpdateCompanionBuilder,
      (
        UploadQueueRow,
        BaseReferences<_$AppDatabase, $UploadQueueTable, UploadQueueRow>,
      ),
      UploadQueueRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$YoutubeAccountsTableTableManager get youtubeAccounts =>
      $$YoutubeAccountsTableTableManager(_db, _db.youtubeAccounts);
  $$AppSettingsRowsTableTableManager get appSettingsRows =>
      $$AppSettingsRowsTableTableManager(_db, _db.appSettingsRows);
  $$UploadQueueTableTableManager get uploadQueue =>
      $$UploadQueueTableTableManager(_db, _db.uploadQueue);
}
