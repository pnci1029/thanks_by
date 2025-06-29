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

class _WriteScreenState extends State<WriteScreen> with TickerProviderStateMixin {
  final _controllers = List.generate(3, (_) => TextEditingController());
  final _minLength = 1;
  final _maxLength = 20;
  String _selectedEmotion = '😊';
  final _emotions = ['😊', '😢', '😡', '😱', '😍', '😐'];
  
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    Future.microtask(() {
      final provider = context.read<DiaryProvider>();
      provider.loadTodayDiary().then((_) {
        if (provider.todayDiary != null && mounted) {
          Fluttertoast.showToast(msg: '오늘 고마웠던 점은 이미 작성했습니다.');
          Navigator.pop(context);
        } else {
          _animationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _animationController.dispose();
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

    setState(() => _isSaving = true);
    
    final provider = context.read<DiaryProvider>();
    final success = await provider.writeDiary(lines, _selectedEmotion);
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Fluttertoast.showToast(msg: '오늘 고마웠던 점이 저장되었습니다!');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: '오늘 고마웠던 점은 이미 작성했습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘 고마웠던 점'),
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: _slideAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 안내 카드
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor.withOpacity(0.1),
                              theme.primaryColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.lightbulb_outline,
                                      color: theme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '오늘 고마웠던 3가지를 작성해주세요',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '각 줄은 1~20자까지 입력 가능합니다',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // 입력 필드들
                    ...List.generate(3, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${i + 1}번째 고마웠던 점',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _controllers[i],
                            maxLength: _maxLength,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: '오늘 고마웠던 점을 입력하세요...',
                              counterText: '${_controllers[i].text.length}/$_maxLength',
                              counterStyle: TextStyle(
                                color: _controllers[i].text.length > _maxLength * 0.8
                                    ? Colors.orange
                                    : theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ],
                      ),
                    )),
                    
                    const SizedBox(height: 32),
                    
                    // 감정 선택
                    Text(
                      '오늘의 감정',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    EmotionTagSelector(
                      tags: _emotions,
                      selectedTag: _selectedEmotion,
                      onChanged: (tag) => setState(() => _selectedEmotion = tag),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveDiary,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                '저장하기',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}