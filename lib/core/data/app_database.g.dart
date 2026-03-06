// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecordsTable extends Records with TableInfo<$RecordsTable, Record> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioSecsMeta = const VerificationMeta(
    'audioSecs',
  );
  @override
  late final GeneratedColumn<int> audioSecs = GeneratedColumn<int>(
    'audio_secs',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathsMeta = const VerificationMeta(
    'imagePaths',
  );
  @override
  late final GeneratedColumn<String> imagePaths = GeneratedColumn<String>(
    'image_paths',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    mood,
    createdAt,
    audioPath,
    audioSecs,
    imagePaths,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'records';
  @override
  VerificationContext validateIntegrity(
    Insertable<Record> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('audio_secs')) {
      context.handle(
        _audioSecsMeta,
        audioSecs.isAcceptableOrUnknown(data['audio_secs']!, _audioSecsMeta),
      );
    }
    if (data.containsKey('image_paths')) {
      context.handle(
        _imagePathsMeta,
        imagePaths.isAcceptableOrUnknown(data['image_paths']!, _imagePathsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Record map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Record(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      audioSecs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_secs'],
      ),
      imagePaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_paths'],
      ),
    );
  }

  @override
  $RecordsTable createAlias(String alias) {
    return $RecordsTable(attachedDatabase, alias);
  }
}

class Record extends DataClass implements Insertable<Record> {
  /// 主键，自增
  final int id;

  /// 文字内容（文字记录时有值）
  final String? content;

  /// 心情标签
  final String mood;

  /// 创建时间：millisecondsSinceEpoch
  final int createdAt;

  /// 音频文件相对路径，如 `audio/voice_1700000000.m4a`
  final String? audioPath;

  /// 录音时长（秒），播放时展示用
  final int? audioSecs;

  /// 图片相对路径列表（JSON 数组），后续扩展用
  final String? imagePaths;
  const Record({
    required this.id,
    this.content,
    required this.mood,
    required this.createdAt,
    this.audioPath,
    this.audioSecs,
    this.imagePaths,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['mood'] = Variable<String>(mood);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    if (!nullToAbsent || audioSecs != null) {
      map['audio_secs'] = Variable<int>(audioSecs);
    }
    if (!nullToAbsent || imagePaths != null) {
      map['image_paths'] = Variable<String>(imagePaths);
    }
    return map;
  }

  RecordsCompanion toCompanion(bool nullToAbsent) {
    return RecordsCompanion(
      id: Value(id),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      mood: Value(mood),
      createdAt: Value(createdAt),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      audioSecs: audioSecs == null && nullToAbsent
          ? const Value.absent()
          : Value(audioSecs),
      imagePaths: imagePaths == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePaths),
    );
  }

  factory Record.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Record(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String?>(json['content']),
      mood: serializer.fromJson<String>(json['mood']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      audioSecs: serializer.fromJson<int?>(json['audioSecs']),
      imagePaths: serializer.fromJson<String?>(json['imagePaths']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String?>(content),
      'mood': serializer.toJson<String>(mood),
      'createdAt': serializer.toJson<int>(createdAt),
      'audioPath': serializer.toJson<String?>(audioPath),
      'audioSecs': serializer.toJson<int?>(audioSecs),
      'imagePaths': serializer.toJson<String?>(imagePaths),
    };
  }

  Record copyWith({
    int? id,
    Value<String?> content = const Value.absent(),
    String? mood,
    int? createdAt,
    Value<String?> audioPath = const Value.absent(),
    Value<int?> audioSecs = const Value.absent(),
    Value<String?> imagePaths = const Value.absent(),
  }) => Record(
    id: id ?? this.id,
    content: content.present ? content.value : this.content,
    mood: mood ?? this.mood,
    createdAt: createdAt ?? this.createdAt,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    audioSecs: audioSecs.present ? audioSecs.value : this.audioSecs,
    imagePaths: imagePaths.present ? imagePaths.value : this.imagePaths,
  );
  Record copyWithCompanion(RecordsCompanion data) {
    return Record(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      mood: data.mood.present ? data.mood.value : this.mood,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      audioSecs: data.audioSecs.present ? data.audioSecs.value : this.audioSecs,
      imagePaths: data.imagePaths.present
          ? data.imagePaths.value
          : this.imagePaths,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Record(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('mood: $mood, ')
          ..write('createdAt: $createdAt, ')
          ..write('audioPath: $audioPath, ')
          ..write('audioSecs: $audioSecs, ')
          ..write('imagePaths: $imagePaths')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    mood,
    createdAt,
    audioPath,
    audioSecs,
    imagePaths,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Record &&
          other.id == this.id &&
          other.content == this.content &&
          other.mood == this.mood &&
          other.createdAt == this.createdAt &&
          other.audioPath == this.audioPath &&
          other.audioSecs == this.audioSecs &&
          other.imagePaths == this.imagePaths);
}

class RecordsCompanion extends UpdateCompanion<Record> {
  final Value<int> id;
  final Value<String?> content;
  final Value<String> mood;
  final Value<int> createdAt;
  final Value<String?> audioPath;
  final Value<int?> audioSecs;
  final Value<String?> imagePaths;
  const RecordsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.mood = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.audioSecs = const Value.absent(),
    this.imagePaths = const Value.absent(),
  });
  RecordsCompanion.insert({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    required String mood,
    required int createdAt,
    this.audioPath = const Value.absent(),
    this.audioSecs = const Value.absent(),
    this.imagePaths = const Value.absent(),
  }) : mood = Value(mood),
       createdAt = Value(createdAt);
  static Insertable<Record> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<String>? mood,
    Expression<int>? createdAt,
    Expression<String>? audioPath,
    Expression<int>? audioSecs,
    Expression<String>? imagePaths,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (mood != null) 'mood': mood,
      if (createdAt != null) 'created_at': createdAt,
      if (audioPath != null) 'audio_path': audioPath,
      if (audioSecs != null) 'audio_secs': audioSecs,
      if (imagePaths != null) 'image_paths': imagePaths,
    });
  }

  RecordsCompanion copyWith({
    Value<int>? id,
    Value<String?>? content,
    Value<String>? mood,
    Value<int>? createdAt,
    Value<String?>? audioPath,
    Value<int?>? audioSecs,
    Value<String?>? imagePaths,
  }) {
    return RecordsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      audioPath: audioPath ?? this.audioPath,
      audioSecs: audioSecs ?? this.audioSecs,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (audioSecs.present) {
      map['audio_secs'] = Variable<int>(audioSecs.value);
    }
    if (imagePaths.present) {
      map['image_paths'] = Variable<String>(imagePaths.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordsCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('mood: $mood, ')
          ..write('createdAt: $createdAt, ')
          ..write('audioPath: $audioPath, ')
          ..write('audioSecs: $audioSecs, ')
          ..write('imagePaths: $imagePaths')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecordsTable records = $RecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [records];
}

typedef $$RecordsTableCreateCompanionBuilder =
    RecordsCompanion Function({
      Value<int> id,
      Value<String?> content,
      required String mood,
      required int createdAt,
      Value<String?> audioPath,
      Value<int?> audioSecs,
      Value<String?> imagePaths,
    });
typedef $$RecordsTableUpdateCompanionBuilder =
    RecordsCompanion Function({
      Value<int> id,
      Value<String?> content,
      Value<String> mood,
      Value<int> createdAt,
      Value<String?> audioPath,
      Value<int?> audioSecs,
      Value<String?> imagePaths,
    });

class $$RecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableFilterComposer({
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

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioSecs => $composableBuilder(
    column: $table.audioSecs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePaths => $composableBuilder(
    column: $table.imagePaths,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableOrderingComposer({
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

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioSecs => $composableBuilder(
    column: $table.audioSecs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePaths => $composableBuilder(
    column: $table.imagePaths,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<int> get audioSecs =>
      $composableBuilder(column: $table.audioSecs, builder: (column) => column);

  GeneratedColumn<String> get imagePaths => $composableBuilder(
    column: $table.imagePaths,
    builder: (column) => column,
  );
}

class $$RecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecordsTable,
          Record,
          $$RecordsTableFilterComposer,
          $$RecordsTableOrderingComposer,
          $$RecordsTableAnnotationComposer,
          $$RecordsTableCreateCompanionBuilder,
          $$RecordsTableUpdateCompanionBuilder,
          (Record, BaseReferences<_$AppDatabase, $RecordsTable, Record>),
          Record,
          PrefetchHooks Function()
        > {
  $$RecordsTableTableManager(_$AppDatabase db, $RecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String> mood = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<int?> audioSecs = const Value.absent(),
                Value<String?> imagePaths = const Value.absent(),
              }) => RecordsCompanion(
                id: id,
                content: content,
                mood: mood,
                createdAt: createdAt,
                audioPath: audioPath,
                audioSecs: audioSecs,
                imagePaths: imagePaths,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> content = const Value.absent(),
                required String mood,
                required int createdAt,
                Value<String?> audioPath = const Value.absent(),
                Value<int?> audioSecs = const Value.absent(),
                Value<String?> imagePaths = const Value.absent(),
              }) => RecordsCompanion.insert(
                id: id,
                content: content,
                mood: mood,
                createdAt: createdAt,
                audioPath: audioPath,
                audioSecs: audioSecs,
                imagePaths: imagePaths,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecordsTable,
      Record,
      $$RecordsTableFilterComposer,
      $$RecordsTableOrderingComposer,
      $$RecordsTableAnnotationComposer,
      $$RecordsTableCreateCompanionBuilder,
      $$RecordsTableUpdateCompanionBuilder,
      (Record, BaseReferences<_$AppDatabase, $RecordsTable, Record>),
      Record,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecordsTableTableManager get records =>
      $$RecordsTableTableManager(_db, _db.records);
}
