import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/memory_item.dart';

class MemoryDatabase {
  static final MemoryDatabase _instance = MemoryDatabase._internal();
  static Database? _database;

  factory MemoryDatabase() => _instance;

  MemoryDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'memories.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE memories('
      'id TEXT PRIMARY KEY, '
      'title TEXT, '
      'content TEXT, '
      'date TEXT, '
      'location TEXT, '
      'mood TEXT, '
      'imagePaths TEXT'
      ')',
    );
  }

  // 插入新的回忆条目
  Future<void> insertMemory(MemoryItem memory) async {
    final db = await database;
    await db.insert(
      'memories',
      {
        'id': memory.id,
        'title': memory.title,
        'content': memory.content,
        'date': memory.date.toIso8601String(),
        'location': memory.location,
        'mood': memory.mood.name,
        'imagePaths': jsonEncode(memory.imagePaths),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取所有回忆条目
  Future<List<MemoryItem>> getMemories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('memories');
    return List.generate(maps.length, (i) {
      return MemoryItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        date: DateTime.parse(maps[i]['date']),
        location: maps[i]['location'],
        mood: Mood.values.firstWhere((e) => e.name == maps[i]['mood']),
        imagePaths: List<String>.from(jsonDecode(maps[i]['imagePaths'])),
      );
    });
  }

  // 获取特定日期的回忆条目
  Future<List<MemoryItem>> getMemoriesByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    
    return List.generate(maps.length, (i) {
      return MemoryItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        date: DateTime.parse(maps[i]['date']),
        location: maps[i]['location'],
        mood: Mood.values.firstWhere((e) => e.name == maps[i]['mood']),
        imagePaths: List<String>.from(jsonDecode(maps[i]['imagePaths'])),
      );
    });
  }

  // 获取特定月份的回忆条目
  Future<List<MemoryItem>> getMemoriesByMonth(int year, int month) async {
    final db = await database;
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
    );
    
    return List.generate(maps.length, (i) {
      return MemoryItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        date: DateTime.parse(maps[i]['date']),
        location: maps[i]['location'],
        mood: Mood.values.firstWhere((e) => e.name == maps[i]['mood']),
        imagePaths: List<String>.from(jsonDecode(maps[i]['imagePaths'])),
      );
    });
  }

  // 获取"那年今日"的回忆条目
  Future<List<MemoryItem>> getMemoriesOnThisDay() async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 获取所有回忆
    final List<Map<String, dynamic>> maps = await db.query('memories');
    
    // 筛选出同月同日的回忆（不同年份）
    return maps.map((map) {
      final memoryDate = DateTime.parse(map['date']);
      if (memoryDate.month == today.month && memoryDate.day == today.day && memoryDate.year != today.year) {
        return MemoryItem(
          id: map['id'],
          title: map['title'],
          content: map['content'],
          date: memoryDate,
          location: map['location'],
          mood: Mood.values.firstWhere((e) => e.name == map['mood']),
          imagePaths: List<String>.from(jsonDecode(map['imagePaths'])),
        );
      }
      return null;
    }).where((item) => item != null).cast<MemoryItem>().toList();
  }

  // 更新回忆条目
  Future<void> updateMemory(MemoryItem memory) async {
    final db = await database;
    await db.update(
      'memories',
      {
        'title': memory.title,
        'content': memory.content,
        'date': memory.date.toIso8601String(),
        'location': memory.location,
        'mood': memory.mood.name,
        'imagePaths': jsonEncode(memory.imagePaths),
      },
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  // 删除回忆条目
  Future<void> deleteMemory(String id) async {
    final db = await database;
    await db.delete(
      'memories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}