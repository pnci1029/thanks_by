import 'package:flutter/material.dart';
import '../data/models/diary.dart';

class DiaryCard extends StatelessWidget {
  final Diary diary;

  const DiaryCard({required this.diary, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${diary.date.year}-${diary.date.month.toString().padLeft(2, '0')}-${diary.date.day.toString().padLeft(2, '0')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...diary.lines.map((line) => Text(line)),
            const SizedBox(height: 6),
            Text('감정: ${diary.emotionTag}', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}