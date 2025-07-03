import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diary_provider.dart';
import '../../data/models/diary.dart';
import '../../widgets/emotion_tag_selector.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => TextEditingController(text: widget.diary.lines[i]),
    );
    _selectedEmotion = widget.diary.emotionTag;
  }

  @override
  void dispose() {
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

    // 한국 시간 기준 오늘 날짜
    final koreaNow = DateTime.now().toUtc().add(const Duration(hours: 9));
    final koreaToday = DateTime(koreaNow.year, koreaNow.month, koreaNow.day);
    final diaryDate = widget.diary.date.toUtc().add(const Duration(hours: 9));
    final diaryDay = DateTime(diaryDate.year, diaryDate.month, diaryDate.day);

    final isEditable = koreaToday == diaryDay;

    return Scaffold(
      appBar: AppBar(title: const Text('고마웠던 점 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _controllers[i],
                maxLength: _maxLength,
                maxLines: 2,
                enabled: isEditable,
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
              onChanged: isEditable ? (tag) => setState(() => _selectedEmotion = tag) : (_) {},
            ),
            const SizedBox(height: 32),
            if (!isEditable)
              Text(
                '고마웠던 점은 작성한 작성일만 수정할 수 있습니다.',
                style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isEditable ? _saveEdit : null,
                child: const Text('수정 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
