import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/pie_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DiaryProvider>().loadAllDiaries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주간 감정 통계')),
      body: Consumer<DiaryProvider>(
        builder: (context, provider, _) {
          final emotionCounts = provider.weeklyEmotionCounts;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text('최근 1주일간 감정 분포', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                EmotionPieChart(emotionCounts: emotionCounts),
              ],
            ),
          );
        },
      ),
    );
  }
}