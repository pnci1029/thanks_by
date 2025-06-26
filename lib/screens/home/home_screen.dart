import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/diary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DiaryProvider>().loadAllDiaries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일기 리스트')),
      body: Consumer<DiaryProvider>(
        builder: (context, provider, _) {
          final diaries = provider.allDiaries;
          if (diaries == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (diaries.isEmpty) {
            return const Center(child: Text('작성된 일기가 없습니다.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: diaries.length,
            itemBuilder: (context, idx) {
              return DiaryCard(diary: diaries[idx]);
            },
          );
        },
      ),
    );
  }
}