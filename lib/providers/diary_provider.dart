import 'package:flutter/material.dart';
import '../data/models/diary.dart';
import '../data/db/diary_database.dart';
import 'package:intl/intl.dart';

class DiaryProvider with ChangeNotifier {
  Diary? _todayDiary;
  List<Diary>? _allDiaries;

  Diary? get todayDiary => _todayDiary;
  List<Diary>? get allDiaries => _allDiaries;

  // 오늘 일기 불러오기
  Future<void> loadTodayDiary() async {
    final today = DateTime.now();
    _todayDiary = await DiaryDatabase.instance.getDiaryByDate(today);
    notifyListeners();
  }

  // 전체 일기 불러오기
  Future<void> loadAllDiaries() async {
    _allDiaries = await DiaryDatabase.instance.getAllDiaries();
    notifyListeners();
  }

  // 일기 작성
  Future<bool> writeDiary(List<String> lines, String emotionTag) async {
    await loadTodayDiary();
    if (_todayDiary != null) return false; // 이미 작성함

    final diary = Diary(
      date: DateTime.now(),
      lines: lines,
      emotionTag: emotionTag,
    );
    await DiaryDatabase.instance.insertDiary(diary);
    _todayDiary = diary;
    await loadAllDiaries();
    notifyListeners();
    return true;
  }

  // 특정 날짜 일기 가져오기 (캘린더용)
  Diary? getDiaryByDate(DateTime date) {
    if (_allDiaries == null) return null;
    final dateStr = date.toIso8601String().substring(0, 10);
    try {
      return _allDiaries!.firstWhere(
        (d) => d.date.toIso8601String().substring(0, 10) == dateStr,
      );
    } catch (_) {
      return null;
    }
  }

  // 최근 1주일간 감정별 카운트
  Map<String, int> get weeklyEmotionCounts {
    if (_allDiaries == null) return {};
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final weekDiaries = _allDiaries!.where((d) {
      final date = DateTime(d.date.year, d.date.month, d.date.day);
      return date.isAfter(weekAgo.subtract(const Duration(days: 1))) && date.isBefore(now.add(const Duration(days: 1)));
    });
    final Map<String, int> counts = {};
    for (final d in weekDiaries) {
      counts[d.emotionTag] = (counts[d.emotionTag] ?? 0) + 1;
    }
    return counts;
  }
}