import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/diary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _showCompletedCard = true;
  bool _showPromptCard = true;
  bool _promptCardExpanded = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    Future.microtask(() {
      final provider = context.read<DiaryProvider>();
      provider.loadAllDiaries();
      provider.loadTodayDiary();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('고마웠던 점'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: '캘린더 보기',
            onPressed: () => Navigator.pushNamed(context, '/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: '감정 통계',
            onPressed: () => Navigator.pushNamed(context, '/stats'),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<DiaryProvider>(
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
                Container(
                  margin: const EdgeInsets.all(16),
                  child: todayDiary == null
                      ? _showPromptCard
                          ? _buildWritePromptCard(theme)
                          : _buildPromptCardCollapsed(theme)
                      : (_showCompletedCard
                          ? _buildTodayCompletedCard(theme)
                          : const SizedBox.shrink()),
                ),

                // 리스트 영역
                Expanded(
                  child: diaries.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildDiaryList(diaries),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPromptCardCollapsed(ThemeData theme) {
    return GestureDetector(
      onTap: () => setState(() => _showPromptCard = true),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_note, color: Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Text(
                '오늘 고마웠던 점 작성하기',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWritePromptCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.edit_note, color: theme.primaryColor, size: 36),
            title: Text(
              '오늘 고마웠던 점을 작성해보세요',
              style: theme.textTheme.titleMedium,
            ),
            trailing: IconButton(
              icon: Icon(_promptCardExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() {
                _promptCardExpanded = !_promptCardExpanded;
                if (!_promptCardExpanded) _showPromptCard = false;
              }),
            ),
          ),
          if (_promptCardExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  Text(
                    '하루에 한 번, 3가지 고마웠던 점을 기록해보세요',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('작성하기'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
        ],
      ),
    );
  }

  Widget _buildTodayCompletedCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.check_circle, color: Colors.green, size: 36),
        title: Text(
          '오늘 고마웠던 점을 작성했습니다!',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '감정: 😊',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: false,
              onChanged: (v) => setState(() => _showCompletedCard = false),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _showCompletedCard = false),
              tooltip: '오늘 하루 닫기',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.disabledColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_add,
              size: 64,
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '아직 작성된 고마웠던 점이 없습니다',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 고마웠던 점을 작성해보세요!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor.withOpacity(0.7),
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
        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: DiaryCard(diary: diaries[idx]),
              ),
            );
          },
        );
      },
    );
  }
}
