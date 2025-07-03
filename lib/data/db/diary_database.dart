import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary.dart';

class DiaryDatabase {
  static final DiaryDatabase instance = DiaryDatabase._init();
  static Database? _database;

  DiaryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE,
        line1 TEXT,
        line2 TEXT,
        line3 TEXT,
        emotionTag TEXT
      )
    ''');
  }

  Future<Diary?> getDiaryByDate(DateTime date) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'diary',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    if (maps.isNotEmpty) {
      return Diary.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertDiary(Diary diary) async {
    final db = await instance.database;
    return await db.insert(
      'diary',
      diary.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Diary>> getAllDiaries() async {
    final db = await instance.database;
    final result = await db.query(
      'diary',
      orderBy: 'date DESC',
    );
    return result.map((map) => Diary.fromMap(map)).toList();
  }

  Future<int> updateDiary(Diary diary) async {
    final db = await instance.database;
    return await db.update(
      'diary',
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }
}