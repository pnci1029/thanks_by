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
    Future.microtask(() {
      final provider = context.read<DiaryProvider>();
      provider.loadAllDiaries();
      provider.loadTodayDiary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('고마웠던 점'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Navigator.pushNamed(context, '/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => Navigator.pushNamed(context, '/stats'),
          ),
        ],
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, provider, _) {
          final diaries = provider.allDiaries;
          final todayDiary = provider.todayDiary;
          
          if (diaries == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // 상단 카드 영역
              Container(
                margin: const EdgeInsets.all(16),
                child: todayDiary == null
                    ? _buildWritePromptCard(theme)
                    : _buildTodayCompletedCard(todayDiary, theme),
              ),
              
              // 리스트 영역
              Expanded(
                child: diaries.isEmpty
                    ? _buildEmptyState()
                    : _buildDiaryList(diaries),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWritePromptCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.edit_note,
              size: 48,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              '오늘 고마웠던 점을 작성해보세요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '하루에 한 번, 3가지 고마웠던 점을 기록해보세요',
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('작성하기'),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/write');
                  if (context.mounted) {
                    context.read<DiaryProvider>().loadAllDiaries();
                    context.read<DiaryProvider>().loadTodayDiary();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCompletedCard(diary, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 48,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              '오늘 고마웠던 점을 작성했습니다!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '감정: ${diary.emotionTag}',
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 작성된 고마웠던 점이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryList(List diaries) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: diaries.length,
      itemBuilder: (context, idx) {
        return DiaryCard(diary: diaries[idx]);
      },
    );
  }
}
