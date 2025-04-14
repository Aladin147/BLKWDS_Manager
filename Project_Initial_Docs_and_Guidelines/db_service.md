// db_service.dart — BLKWDS Manager
// Handles all SQLite operations using sqflite package

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'blkwds_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE gear (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        thumbnailPath TEXT,
        isOut INTEGER,
        lastNote TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE member (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        role TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE project (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        client TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE booking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projectId INTEGER,
        startDate TEXT,
        endDate TEXT,
        isRecordingStudio INTEGER,
        isProductionStudio INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE booking_gear (
        bookingId INTEGER,
        gearId INTEGER,
        assignedMemberId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE status_note (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gearId INTEGER,
        note TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE activity_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gearId INTEGER,
        memberId INTEGER,
        checkedOut INTEGER,
        timestamp TEXT,
        note TEXT
      )
    ''');
  }

  // Add CRUD methods here (examples only)
  static Future<int> insertGear(Map<String, dynamic> gear) async {
    final db = await database;
    return await db.insert('gear', gear);
  }

  static Future<List<Map<String, dynamic>>> getAllGear() async {
    final db = await database;
    return await db.query('gear');
  }

  static Future<int> updateGear(int id, Map<String, dynamic> gear) async {
    final db = await database;
    return await db.update('gear', gear, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteGear(int id) async {
    final db = await database;
    return await db.delete('gear', where: 'id = ?', whereArgs: [id]);
  }

  // Add similar methods for member, project, booking, etc.
}
