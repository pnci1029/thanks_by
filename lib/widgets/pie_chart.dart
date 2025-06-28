import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EmotionPieChart extends StatelessWidget {
  final Map<String, int> emotionCounts;

  const EmotionPieChart({required this.emotionCounts, super.key});

  @override
  Widget build(BuildContext context) {
    final total = emotionCounts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return const Center(child: Text('최근 1주일간 작성된 고마웠던 점이 없습니다.'));
    }

    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.grey,
    ];

    final entries = emotionCounts.entries.toList();

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: List.generate(entries.length, (i) {
            final e = entries[i];
            final percent = (e.value / total * 100).toStringAsFixed(1);
            return PieChartSectionData(
              color: colors[i % colors.length],
              value: e.value.toDouble(),
              title: '${e.key} ($percent%)',
              radius: 80,
              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}