import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/emotion_tag_selector.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _controllers = List.generate(3, (_) => TextEditingController());
  final _maxLength = 100;
  String _selectedEmotion = '😊';
  final _emotions = ['😊', '😢', '😡', '😱', '😍', '😐'];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveDiary() async {
    final lines = _controllers.map((c) => c.text.trim()).toList();
    if (lines.any((line) => line.isEmpty)) {
      Fluttertoast.showToast(msg: '모든 줄을 입력해 주세요.');
      return;
    }
    if (lines.any((line) => line.length > _maxLength)) {
      Fluttertoast.showToast(msg: '각 줄은 최대 $_maxLength자까지 입력 가능합니다.');
      return;
    }

    final provider = context.read<DiaryProvider>();
    final success = await provider.writeDiary(lines, _selectedEmotion);
    if (success) {
      Fluttertoast.showToast(msg: '일기가 저장되었습니다!');
      if (mounted) Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: '오늘 일기는 이미 작성했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 일기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _controllers[i],
                maxLength: _maxLength,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: '${i + 1}번째 줄',
                  border: const OutlineInputBorder(),
                ),
              ),
            )),
            const SizedBox(height: 16),
            EmotionTagSelector(
              tags: _emotions,
              selectedTag: _selectedEmotion,
              onChanged: (tag) => setState(() => _selectedEmotion = tag),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveDiary,
              child: const Text('저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}