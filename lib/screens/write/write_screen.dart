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
  final _minLength = 1;
  final _maxLength = 20;
  String _selectedEmotion = '😊';
  final _emotions = ['😊', '😢', '😡', '😱', '😍', '😐'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<DiaryProvider>();
      provider.loadTodayDiary().then((_) {
        if (provider.todayDiary != null && mounted) {
          Fluttertoast.showToast(msg: '오늘 고마웠던 점은 이미 작성했습니다.');
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveDiary() async {
    final lines = _controllers.map((c) => c.text.trim()).toList();
    if (lines.any((line) => line.length < _minLength)) {
      Fluttertoast.showToast(msg: '각 줄을 1자 이상 입력해 주세요.');
      return;
    }
    if (lines.any((line) => line.length > _maxLength)) {
      Fluttertoast.showToast(msg: '각 줄은 최대 $_maxLength자까지 입력 가능합니다.');
      return;
    }

    final provider = context.read<DiaryProvider>();
    final success = await provider.writeDiary(lines, _selectedEmotion);
    if (success) {
      Fluttertoast.showToast(msg: '오늘 고마웠던 점이 저장되었습니다!');
      if (mounted) Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: '오늘 고마웠던 점은 이미 작성했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘 고마웠던 점')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘 고마웠던 3가지를 작성해주세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '각 줄은 1~20자까지 입력 가능합니다',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 입력 필드들
            ...List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}번째 고마웠던 점',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controllers[i],
                    maxLength: _maxLength,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: '오늘 고마웠던 점을 입력하세요...',
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 24),
            
            // 감정 선택
            const Text(
              '오늘의 감정',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            EmotionTagSelector(
              tags: _emotions,
              selectedTag: _selectedEmotion,
              onChanged: (tag) => setState(() => _selectedEmotion = tag),
            ),
            
            const SizedBox(height: 32),
            
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDiary,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '저장하기',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}