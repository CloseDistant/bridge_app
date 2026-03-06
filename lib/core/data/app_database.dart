import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ── 表定义 ─────────────────────────────────────────────────────────────────

/// 记录表：文字 / 语音 / 图片（后续扩展）统一存这里。
/// 二进制文件本身只存 *相对路径*，拼接由 [RecordRepository] 负责。
class Records extends Table {
  /// 主键，自增
  IntColumn get id => integer().autoIncrement()();

  /// 文字内容（文字记录时有值）
  TextColumn get content => text().nullable()();

  /// 心情标签
  TextColumn get mood => text()();

  /// 创建时间：millisecondsSinceEpoch
  IntColumn get createdAt => integer()();

  /// 音频文件相对路径，如 `audio/voice_1700000000.m4a`
  TextColumn get audioPath => text().nullable()();

  /// 录音时长（秒），播放时展示用
  IntColumn get audioSecs => integer().nullable()();

  /// 图片相对路径列表（JSON 数组），后续扩展用
  TextColumn get imagePaths => text().nullable()();
}

// ── 数据库 ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [Records])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ---- 查询 ----

  /// 监听所有记录（Stream，UI 可直接 StreamBuilder）
  Stream<List<Record>> watchAll() =>
      (select(records)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// 一次性获取所有记录（按时间倒序）
  Future<List<Record>> getAll() =>
      (select(records)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// 按关键词搜索文字内容
  Future<List<Record>> searchText(String keyword) => (select(records)
        ..where((t) => t.content.like('%$keyword%'))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();

  // ---- 写入 ----

  Future<int> addRecord(RecordsCompanion entry) =>
      into(records).insert(entry);

  Future<int> removeRecord(int id) =>
      (delete(records)..where((t) => t.id.equals(id))).go();
}

// ── 连接工厂 ────────────────────────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bridge_records.db'));
    return NativeDatabase.createInBackground(file);
  });
}
