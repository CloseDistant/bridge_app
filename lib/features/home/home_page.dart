import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../theme/tokens/app_space.dart';

enum _InputMode { text, voice }

class _HomeRecord {
  _HomeRecord({
    required this.content,
    required this.mood,
    required this.createdAt,
  });

  final String content;
  final String mood;
  final DateTime createdAt;
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

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  _InputMode _inputMode = _InputMode.text;
  String _selectedMood = '平静';

  final List<String> _moods = const <String>[
    '开心',
    '平静',
    '焦虑',
    '疲惫',
    '生气',
    '难过',
  ];

  final List<_HomeRecord> _records = <_HomeRecord>[];

  @override
  void initState() {
    super.initState();
    _records.addAll(<_HomeRecord>[
      _HomeRecord(
        content: '今天完成了主页 UI 的第一版。',
        mood: '开心',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      _HomeRecord(
        content: '准备把语音输入接入到后端识别。',
        mood: '平静',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);

    _initSpeechToText();
  }

  @override
  void dispose() {
    _speech.stop();
    _searchController.dispose();
    _inputController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final auth = Get.find<AuthService>();
    await auth.logout();
    Get.offAllNamed(Routes.login);
  }

  Future<void> _initSpeechToText() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() {
          _isListening = status == 'listening';
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('语音识别错误：${error.errorMsg}')));
      },
    );

    if (!mounted) return;
    setState(() {
      _speechAvailable = available;
    });
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('语音识别不可用，请检查权限或系统语音服务')));
      return;
    }

    await _speech.listen(
      localeId: 'zh_CN',
      partialResults: true,
      onResult: (result) {
        final words = result.recognizedWords;
        _inputController.value = _inputController.value.copyWith(
          text: words,
          selection: TextSelection.collapsed(offset: words.length),
          composing: TextRange.empty,
        );
        if (!mounted) return;
        setState(() {});
      },
    );

    if (!mounted) return;
    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  void _sendRecord() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (_isListening) {
      _stopListening();
    }

    setState(() {
      _records.insert(
        0,
        _HomeRecord(
          content: text,
          mood: _selectedMood,
          createdAt: DateTime.now(),
        ),
      );
      _inputController.clear();
    });

    if (_listController.hasClients) {
      _listController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  List<_HomeRecord> get _filteredRecords {
    final query = _searchController.text.trim();
    if (query.isEmpty) return _records;
    return _records.where((r) => r.content.contains(query)).toList();
  }

  String _formatTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSend = _inputController.text.trim().isNotEmpty;

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
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              tooltip: '菜单',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        titleSpacing: 0,
        title: const Text('主页'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.space12),
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 240),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '搜索记录',
                  isDense: true,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        controller: _listController,
        padding: const EdgeInsets.all(AppSpace.space16),
        itemCount: _filteredRecords.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpace.space12),
        itemBuilder: (BuildContext context, int index) {
          final record = _filteredRecords[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.space12),
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
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          record.mood,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(record.createdAt),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.space8),
                  Text(record.content, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
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
                Wrap(
                  spacing: AppSpace.space8,
                  runSpacing: AppSpace.space8,
                  children: _moods
                      .map(
                        (mood) => ChoiceChip(
                          label: Text(mood),
                          selected: mood == _selectedMood,
                          onSelected: (_) =>
                              setState(() => _selectedMood = mood),
                        ),
                      )
                      .toList(),
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
                      onPressed: () {
                        setState(() {
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
                              onSubmitted: (_) => _sendRecord(),
                              decoration: InputDecoration(
                                hintText: '记录一下…',
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: _toggleListening,
                              icon: Icon(_isListening ? Icons.stop : Icons.mic),
                              label: Text(
                                _isListening
                                    ? '停止识别'
                                    : (_speechAvailable ? '点击开始语音' : '语音不可用'),
                              ),
                            ),
                    ),
                    const SizedBox(width: AppSpace.space8),
                    IconButton(
                      tooltip: '发送',
                      icon: const Icon(Icons.send),
                      onPressed: canSend ? _sendRecord : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
