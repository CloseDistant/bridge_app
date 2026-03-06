import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../app/routes/app_routes.dart';
import '../../core/data/app_database.dart';
import '../../core/data/record_repository.dart';
import '../../core/services/auth_service.dart';
import '../../theme/tokens/app_space.dart';

enum _InputMode { text, voice }

class _HomeRecord {
  _HomeRecord({
    this.id,
    required this.mood,
    required this.createdAt,
    this.content,
    this.audioPath,
    this.audioDuration,
  });

  /// 对应数据库主键，内存临时记录为 null
  final int? id;
  final String? content;

  /// 运行时绝对路径（从 DB 相对路径还原后赋值）
  final String? audioPath;
  final Duration? audioDuration;
  final String mood;
  final DateTime createdAt;

  bool get isVoice => audioPath != null;

  static _HomeRecord fromDb(Record r, {required String? resolvedAudioPath}) {
    return _HomeRecord(
      id: r.id,
      content: r.content,
      mood: r.mood,
      createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
      audioPath: resolvedAudioPath,
      audioDuration:
          r.audioSecs != null ? Duration(seconds: r.audioSecs!) : null,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _inputController = TextEditingController();
  final _listController = ScrollController();

  late final AppDatabase _db;
  late final RecordRepository _repo;
  static const _uuid = Uuid();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _currentlyPlayingPath;
  bool _isLoading = true;

  _InputMode _inputMode = _InputMode.text;
  String _selectedMood = '平静';
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  // ── 多选删除 ───────────────────────────────────────────────────────────────
  bool _isSelecting = false;
  final Set<int> _selectedIds = {};

  final List<String> _moods = const <String>[
    '开心',
    '平静',
    '焦虑',
    '疲惫',
    '生气',
    '难过',
  ];

  static const Map<String, String> _moodEmojis = <String, String>{
    '开心': '😊',
    '平静': '😌',
    '焦虑': '😰',
    '疲惫': '😴',
    '生气': '😠',
    '难过': '😢',
  };

  final List<_HomeRecord> _records = <_HomeRecord>[];

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _repo = RecordRepository(_db);

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => _currentlyPlayingPath = null);
    });
 
    _loadRecords();
  }

 
  Future<void> _loadRecords() async {
    final dbRecords = await _repo.getAll();
    final uiRecords = await Future.wait(
      dbRecords.map((r) async {
        String? resolvedPath;
        if (r.audioPath != null) {
          resolvedPath = await _repo.resolveFullPath(r.audioPath!);
        }
        return _HomeRecord.fromDb(r, resolvedAudioPath: resolvedPath);
      }),
    );
    if (!mounted) return;
    setState(() {
      _records
        ..clear()
        ..addAll(uiRecords);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _inputController.dispose();
    _listController.dispose();
    _db.close();
    super.dispose();
  }

  Future<void> _logout() async {
    final auth = Get.find<AuthService>();
    await auth.logout();
    Get.offAllNamed(Routes.login);
  }

  // ── 录音 ──────────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    if (_isRecording) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未获得麦克风权限，请在系统设置中授予麦克风权限')),
      );
      return;
    }
    try {
      final audioDir = await RecordRepository.audioDirectory();
      final filename = 'voice_${_uuid.v4()}.m4a';
      final path = '$audioDir/$filename';
      await _recorder.start(const RecordConfig(), path: path);
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _recordingDuration += const Duration(seconds: 1));
      });
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('录音启动失败：$e')));
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    _recordingTimer?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;
    final duration = _recordingDuration;
    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });
    if (path == null) return;
    if (duration.inMilliseconds < 500) {
      try {
        File(path).deleteSync();
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('录音时间太短，请按住后再说话')),
      );
      return;
    }
    // 持久化到数据库
    final savedRecord = await _repo.addVoiceRecord(
      absolutePath: path,
      durationSecs: duration.inSeconds.clamp(1, 9999),
      mood: _selectedMood,
    );
    if (!mounted) return;
    setState(() {
      _records.insert(
        0,
        _HomeRecord(
          id: savedRecord.id,
          audioPath: path, // 已是绝对路径，直接用于播放
          audioDuration: duration,
          mood: _selectedMood,
          createdAt: DateTime.fromMillisecondsSinceEpoch(savedRecord.createdAt),
        ),
      );
      if (_isSearching) {
        _isSearching = false;
        _searchController.clear();
      }
    });
    if (_listController.hasClients) {
      _listController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) return;
    _recordingTimer?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });
    if (path != null) {
      try {
        File(path).deleteSync();
      } catch (_) {}
    }
  }

  // ── 播放 ──────────────────────────────────────────────────────────────────

  Future<void> _togglePlayback(String path) async {
    if (_currentlyPlayingPath == path) {
      await _player.stop();
      if (!mounted) return;
      setState(() => _currentlyPlayingPath = null);
    } else {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      if (!mounted) return;
      setState(() => _currentlyPlayingPath = path);
    }
  }

  // ── 文字记录 ──────────────────────────────────────────────────────────────

  Future<void> _sendTextRecord() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    // 先清空输入框，提升交互响应感
    setState(() {
      _inputController.clear();
      if (_isSearching) {
        _isSearching = false;
        _searchController.clear();
      }
    });
    // 持久化到数据库
    final saved = await _repo.addTextRecord(
      content: text,
      mood: _selectedMood,
    );
    if (!mounted) return;
    setState(() {
      _records.insert(
        0,
        _HomeRecord(
          id: saved.id,
          content: text,
          mood: _selectedMood,
          createdAt: DateTime.fromMillisecondsSinceEpoch(saved.createdAt),
        ),
      );
    });
    if (_listController.hasClients) {
      _listController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  // ── 选择模式操作 ────────────────────────────────────────────────────────────

  void _enterSelectMode(int id) {
    setState(() {
      _isSelecting = true;
      _selectedIds.add(id);
      if (_isSearching) {
        _isSearching = false;
        _searchController.clear();
      }
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _exitSelectMode() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  Future<void> _confirmAndDelete() async {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定删除选中的 $count 条记录吗？此操作不可撤销。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // 停止正在播放的音频（若被删除）
    if (_currentlyPlayingPath != null) {
      final deletingPaths = _records
          .where((r) => r.id != null && _selectedIds.contains(r.id))
          .map((r) => r.audioPath)
          .whereType<String>()
          .toSet();
      if (deletingPaths.contains(_currentlyPlayingPath)) {
        await _player.stop();
        if (!mounted) return;
        setState(() => _currentlyPlayingPath = null);
      }
    }

    // 从 DB 和磁盘删除
    final toDelete = _records
        .where((r) => r.id != null && _selectedIds.contains(r.id))
        .toList();
    for (final r in toDelete) {
      await _repo.deleteRecordById(r.id!, absoluteAudioPath: r.audioPath);
    }
    if (!mounted) return;
    setState(() {
      _records.removeWhere((r) => r.id != null && _selectedIds.contains(r.id));
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  List<_HomeRecord> get _filteredRecords {
    final query = _searchController.text.trim();
    if (query.isEmpty) return _records;
    return _records
        .where((r) => r.content != null && r.content!.contains(query))
        .toList();
  }

  String _formatTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSend = _inputController.text.trim().isNotEmpty;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: const Text('已登录用户'),
                accountEmail: const Text('个人内容 / 资料入口'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.primaryContainer,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('个人资料'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('个人资料：待接入')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('设置'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('设置：待接入')));
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('退出登录'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _logout();
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: RotationTransition(
              turns: Tween<double>(
                begin: 0.875,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          ),
          child: _isSelecting
              ? IconButton(
                  key: const ValueKey('select_close'),
                  tooltip: '退出选择',
                  icon: const Icon(Icons.close),
                  onPressed: _exitSelectMode,
                )
              : _isSearching
              ? IconButton(
                  key: const ValueKey('back'),
                  tooltip: '取消',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                )
              : Builder(
                  key: const ValueKey('menu'),
                  builder: (BuildContext context) {
                    return IconButton(
                      tooltip: '菜单',
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    );
                  },
                ),
        ),
        titleSpacing: _isSearching ? 0 : null,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          ),
          child: _isSelecting
              ? Text(
                  '已选 ${_selectedIds.length} 项',
                  key: const ValueKey('select_title'),
                )
              : _isSearching
              ? TextField(
                  key: const ValueKey('search_field'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: '搜索记录…',
                    border: InputBorder.none,
                  ),
                )
              : const Text('主页', key: ValueKey('title_text')),
        ),
        actions: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            ),
            child: _isSelecting
                ? Row(
                    key: const ValueKey('select_actions'),
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: '删除所选',
                        icon: Icon(
                          Icons.delete_outline,
                          color: _selectedIds.isNotEmpty
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        ),
                        onPressed: _selectedIds.isNotEmpty ? _confirmAndDelete : null,
                      ),
                      IconButton(
                        tooltip: '取消选择',
                        icon: const Icon(Icons.deselect),
                        onPressed: _exitSelectMode,
                      ),
                    ],
                  )
                : !_isSearching
                ? IconButton(
                    key: const ValueKey('search_icon'),
                    tooltip: '搜索',
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() => _isSearching = true),
                  )
                : _searchController.text.isNotEmpty
                    ? IconButton(
                        key: const ValueKey('clear_icon'),
                        tooltip: '清空',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          _searchFocusNode.requestFocus();
                        },
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _filteredRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          _isSearching
                              ? Icons.search_off_rounded
                              : Icons.inbox_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.4),
                        ),
                        const SizedBox(height: AppSpace.space12),
                        Text(
                          _isSearching ? '没有找到相关记录' : '还没有任何记录',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
              controller: _listController,
              padding: const EdgeInsets.all(AppSpace.space16),
              itemCount: _filteredRecords.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpace.space12),
              itemBuilder: (BuildContext context, int index) {
                final record = _filteredRecords[index];
                final isSelected =
                    record.id != null && _selectedIds.contains(record.id);
                return GestureDetector(
                  onLongPress: () {
                    if (record.id != null) _enterSelectMode(record.id!);
                  },
                  child: Card(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer.withOpacity(0.45)
                        : null,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: (_isSelecting && record.id != null)
                          ? () => _toggleSelect(record.id!)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpace.space12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (_isSelecting)
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpace.space8,
                                  top: 2,
                                ),
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: record.id != null
                                      ? (_) => _toggleSelect(record.id!)
                                      : null,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpace.space8,
                                          vertical: AppSpace.space4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '${_moodEmojis[record.mood] ?? ''} ${record.mood}',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatTime(record.createdAt),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpace.space8),
                                  if (record.isVoice)
                                    _VoiceRecordTile(
                                      duration: record.audioDuration!,
                                      isPlaying: _currentlyPlayingPath ==
                                          record.audioPath,
                                      onTap: () =>
                                          _togglePlayback(record.audioPath!),
                                    )
                                  else
                                    Text(
                                      record.content!,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Material(
              elevation: 8,
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.space16,
                  AppSpace.space12,
                  AppSpace.space16,
                  AppSpace.space12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _moods
                            .map(
                              (mood) => Padding(
                                padding: const EdgeInsets.only(
                                    right: AppSpace.space8),
                                child: ChoiceChip(
                                  label: Text(
                                    '${_moodEmojis[mood] ?? ''} $mood',
                                  ),
                                  showCheckmark: false,
                                  selected: mood == _selectedMood,
                                  onSelected: (_) =>
                                      setState(() => _selectedMood = mood),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpace.space12),
                    Row(
                      children: <Widget>[
                        IconButton(
                          tooltip: _inputMode == _InputMode.text
                              ? '切换到语音'
                              : '切换到文字',
                          icon: Icon(
                            _inputMode == _InputMode.text
                                ? Icons.mic_none_outlined
                                : Icons.keyboard_outlined,
                          ),
                          onPressed: () async {
                            if (_isRecording) await _cancelRecording();
                            setState(() {
                              if (_isSearching) {
                                _isSearching = false;
                                _searchController.clear();
                              }
                              _inputMode = _inputMode == _InputMode.text
                                  ? _InputMode.voice
                                  : _InputMode.text;
                            });
                          },
                        ),
                        const SizedBox(width: AppSpace.space8),
                        Expanded(
                          child: _inputMode == _InputMode.text
                              ? TextField(
                                  controller: _inputController,
                                  minLines: 1,
                                  maxLines: 4,
                                  textInputAction: TextInputAction.send,
                                  onChanged: (_) => setState(() {}),
                                  onSubmitted: (_) => _sendTextRecord(),
                                  decoration: InputDecoration(
                                    hintText: '记录一下…',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                )
                              : _VoiceRecordButton(
                                  isRecording: _isRecording,
                                  duration: _recordingDuration,
                                  onRecordStart: _startRecording,
                                  onRecordStop: _stopRecording,
                                  onRecordCancel: _cancelRecording,
                                ),
                        ),
                        if (_inputMode == _InputMode.text) ...[
                          const SizedBox(width: AppSpace.space8),
                          IconButton(
                            tooltip: '发送',
                            icon: const Icon(Icons.send),
                            onPressed: canSend ? _sendTextRecord : null,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ── Sub-widgets ────────────────────────────────────────────────────────────

class _VoiceRecordButton extends StatefulWidget {
  const _VoiceRecordButton({
    required this.isRecording,
    required this.duration,
    required this.onRecordStart,
    required this.onRecordStop,
    required this.onRecordCancel,
  });

  final bool isRecording;
  final Duration duration;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordStop;
  final VoidCallback onRecordCancel;

  @override
  State<_VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<_VoiceRecordButton> {
  bool _isCancelMode = false;
  double _startY = 0;
  static const double _cancelThreshold = 60.0;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color bgColor;
    final Color fgColor;
    if (!widget.isRecording) {
      bgColor = theme.colorScheme.primaryContainer;
      fgColor = theme.colorScheme.onPrimaryContainer;
    } else if (_isCancelMode) {
      bgColor = theme.colorScheme.error;
      fgColor = theme.colorScheme.onError;
    } else {
      bgColor = theme.colorScheme.errorContainer;
      fgColor = theme.colorScheme.onErrorContainer;
    }

    return Listener(
      onPointerDown: (PointerDownEvent e) {
        _startY = e.position.dy;
        if (_isCancelMode) setState(() => _isCancelMode = false);
        widget.onRecordStart();
      },
      onPointerMove: (PointerMoveEvent e) {
        if (!widget.isRecording) return;
        final dy = _startY - e.position.dy;
        final entering = dy > _cancelThreshold;
        if (entering != _isCancelMode) {
          setState(() => _isCancelMode = entering);
        }
      },
      onPointerUp: (_) {
        final cancel = _isCancelMode;
        setState(() => _isCancelMode = false);
        if (cancel) {
          widget.onRecordCancel();
        } else {
          widget.onRecordStop();
        }
      },
      onPointerCancel: (_) {
        setState(() => _isCancelMode = false);
        widget.onRecordCancel();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: widget.isRecording
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: _isCancelMode
                        ? Icon(
                            Icons.delete_outline,
                            key: const ValueKey('del'),
                            color: fgColor,
                            size: 20,
                          )
                        : Icon(
                            Icons.mic,
                            key: const ValueKey('mic'),
                            color: fgColor,
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: Text(
                      _isCancelMode
                          ? '松开取消'
                          : '松开结束  ${_fmt(widget.duration)}',
                      key: ValueKey(_isCancelMode),
                      style:
                          theme.textTheme.bodyMedium?.copyWith(color: fgColor),
                    ),
                  ),
                  if (!_isCancelMode) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.arrow_upward,
                      color: fgColor.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '上滑取消',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: fgColor.withOpacity(0.6)),
                    ),
                  ],
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.mic, color: fgColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '按住录音',
                    style:
                        theme.textTheme.bodyMedium?.copyWith(color: fgColor),
                  ),
                ],
              ),
      ),
    );
  }
}

class _VoiceRecordTile extends StatelessWidget {
  const _VoiceRecordTile({
    required this.duration,
    required this.isPlaying,
    required this.onTap,
  });

  final Duration duration;
  final bool isPlaying;
  final VoidCallback onTap;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.space12,
          vertical: AppSpace.space8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              _fmt(duration),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}