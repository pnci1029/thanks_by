import 'package:flutter/material.dart';
import '../data/models/diary.dart';
import '../data/db/diary_database.dart';

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
}