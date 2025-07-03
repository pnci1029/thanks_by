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

  bool _isEditable = false;
  Timer? _timer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,

      (i) => TextEditingController(text: widget.diary.lines[i]),
    );
    _selectedEmotion = widget.diary.emotionTag;
    _updateEditable();
    if (_isEditable) {
      _updateRemainingTime();
      _timer =
          Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());
    }
  }

  void _updateEditable() {
    final nowKst = getKstDate(DateTime.now());
    final diaryKst = getKstDate(widget.diary.date);
    setState(() {
      _isEditable = nowKst == diaryKst;
    });
  }

  void _updateRemainingTime() {
    final nowKst = DateTime.now().toUtc().add(const Duration(hours: 9));
    final midnightKst = DateTime.utc(nowKst.year, nowKst.month, nowKst.day + 1);
    final remaining = midnightKst.difference(nowKst);

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    setState(() {
      _remainingTime =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
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
    return Scaffold(
      appBar: AppBar(title: const Text('고마웠던 점 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditable)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Center(
                  child: Text(
                    '오늘까지 수정 가능합니다! (남은 시간: $_remainingTime)',
                    style: TextStyle(
                    
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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

  DateTime getKstDate(DateTime dt) {
    final kst = dt.toUtc().add(const Duration(hours: 9));
    return DateTime(kst.year, kst.month, kst.day);
  }
}
