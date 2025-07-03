import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diary_provider.dart';
import '../../data/models/diary.dart';
import '../../widgets/emotion_tag_selector.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

class EditScreen extends StatefulWidget {
  final Diary diary;
  const EditScreen({super.key, required this.diary});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late List<TextEditingController> _controllers;
  late String _selectedEmotion;
  final _maxLength = 20;

  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => TextEditingController(text: widget.diary.lines[i]),
    );
    _selectedEmotion = widget.diary.emotionTag;
    _updateEditableAndTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateEditableAndTimer());
  }

  void _updateEditableAndTimer() {
    final nowKst = DateTime.now().toUtc().add(const Duration(hours: 9));
    final todayKst = DateTime(nowKst.year, nowKst.month, nowKst.day);
    final diaryDateKst = widget.diary.date.toUtc().add(const Duration(hours: 9));
    final diaryDayKst = DateTime(diaryDateKst.year, diaryDateKst.month, diaryDateKst.day);

    final isToday = todayKst == diaryDayKst;
    final nextMidnight = DateTime(nowKst.year, nowKst.month, nowKst.day + 1);
    final left = nextMidnight.difference(nowKst);

    setState(() {
      _isEditable = isToday && left.inSeconds > 0;
      _timeLeft = left;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  void _saveEdit() async {
    final lines = _controllers.map((c) => c.text.trim()).toList();
    if (lines.any((line) => line.isEmpty)) {
      Fluttertoast.showToast(msg: '각 줄을 1자 이상 입력해 주세요.');
      return;
    }
    if (lines.any((line) => line.length > _maxLength)) {
      Fluttertoast.showToast(msg: '각 줄은 최대 $_maxLength자까지 입력 가능합니다.');
      return;
    }

    final provider = context.read<DiaryProvider>();
    final updated = Diary(
      id: widget.diary.id,
      date: widget.diary.date,
      lines: lines,
      emotionTag: _selectedEmotion,
    );
    await provider.updateDiary(updated);
    Fluttertoast.showToast(msg: '수정되었습니다!');
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String formatDuration(Duration d) {
      final h = d.inHours.toString().padLeft(2, '0');
      final m = (d.inMinutes % 60).toString().padLeft(2, '0');
      final s = (d.inSeconds % 60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('고마웠던 점 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditable)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 18, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      '오늘 자정까지 남은 시간: ',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      formatDuration(_timeLeft),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ...List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _controllers[i],
                maxLength: _maxLength,
                maxLines: 2,
                enabled: _isEditable,
                decoration: InputDecoration(
                  labelText: '${i + 1}번째 고마웠던 점',
                  border: const OutlineInputBorder(),
                ),
              ),
            )),
            const SizedBox(height: 24),
            const Text('감정 태그', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            EmotionTagSelector(
              tags: ['😊', '😢', '😡', '😱', '😍', '😐'],
              selectedTag: _selectedEmotion,
              onChanged: _isEditable ? (tag) => setState(() => _selectedEmotion = tag) : (_) {},
            ),
            const SizedBox(height: 32),
            if (!_isEditable)
              Text(
                '고마웠던 점은 작성한 작성일만 수정할 수 있습니다.',
                style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isEditable ? _saveEdit : null,
                child: const Text('수정 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
