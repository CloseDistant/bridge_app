import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// 本地记录仓库
///
/// 规则：
/// * 数据库只存 *相对路径*（`audio/xxx.m4a`、`images/xxx.jpg`）
/// * [resolveFullPath] 在运行时将相对路径拼成绝对路径
/// * 外部调用者传入绝对路径时，本类负责转换为相对路径再入库
class RecordRepository {
  RecordRepository(this._db);

  final AppDatabase _db;

  // ── 查询 ───────────────────────────────────────────────────────────────

  /// 一次性加载全部记录（按创建时间倒序）
  Future<List<Record>> getAll() => _db.getAll();

  /// 监听全部记录的变更（响应式）
  Stream<List<Record>> watchAll() => _db.watchAll();

  // ── 写入：文字 ─────────────────────────────────────────────────────────

  Future<Record> addTextRecord({
    required String content,
    required String mood,
  }) async {
    final id = await _db.addRecord(
      RecordsCompanion.insert(
        content: Value(content),
        mood: mood,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return _db.getAll().then((list) => list.firstWhere((r) => r.id == id));
  }

  // ── 写入：语音 ─────────────────────────────────────────────────────────

  /// [absolutePath]  录音完成后的绝对路径
  /// [durationSecs]  录音时长（秒）
  Future<Record> addVoiceRecord({
    required String absolutePath,
    required int durationSecs,
    required String mood,
  }) async {
    final relative = await _toRelative(absolutePath);
    final id = await _db.addRecord(
      RecordsCompanion.insert(
        mood: mood,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        audioPath: Value(relative),
        audioSecs: Value(durationSecs),
      ),
    );
    return _db.getAll().then((list) => list.firstWhere((r) => r.id == id));
  }

  // ── 删除 ────────────────────────────────────────────────────────────────

  /// 删除记录，同时删除关联的文件（音频 / 图片）
  Future<void> deleteRecord(Record record) async {
    final base = (await getApplicationDocumentsDirectory()).path;

    // 删除音频文件
    if (record.audioPath != null) {
      _tryDeleteFile('$base/${record.audioPath}');
    }

    // 删除图片文件（TODO：imagePaths JSON 解析，后续扩展时补充）

    await _db.removeRecord(record.id);
  }

  /// 通过主键删除记录，[absoluteAudioPath] 为音频的绝对路径（由调用方从界面层传入）
  Future<void> deleteRecordById(int id, {String? absoluteAudioPath}) async {
    if (absoluteAudioPath != null) {
      _tryDeleteFile(absoluteAudioPath);
    }
    // 图片文件：后续扩展在此补充
    await _db.removeRecord(id);
  }

  // ── 路径工具 ────────────────────────────────────────────────────────────

  /// 将相对路径还原为当前设备的绝对路径
  Future<String> resolveFullPath(String relativePath) async {
    final base = (await getApplicationDocumentsDirectory()).path;
    return '$base/$relativePath';
  }

  /// 将绝对路径转换为相对于 appDocumentsDirectory 的路径
  Future<String> _toRelative(String absolutePath) async {
    final base = (await getApplicationDocumentsDirectory()).path;
    if (absolutePath.startsWith('$base/')) {
      return absolutePath.substring(base.length + 1);
    }
    return absolutePath;
  }

  void _tryDeleteFile(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }

  // ── 音频目录 ────────────────────────────────────────────────────────────

  /// 返回用于存放音频文件的绝对目录，不存在时自动创建
  static Future<String> audioDirectory() async {
    final base = (await getApplicationDocumentsDirectory()).path;
    final dir = Directory('$base/audio');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }
}
