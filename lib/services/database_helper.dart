import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/screening_record.dart';
import '../models/user_profile.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('eye_disease_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Patient / User Information Table
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        dateOfBirth TEXT,
        gender TEXT NOT NULL,
        wearsGlasses INTEGER NOT NULL,
        familyHistory INTEGER NOT NULL,
        averageScreenTimeHours INTEGER NOT NULL,
        commonSymptoms TEXT NOT NULL,
        eyeHealthScore INTEGER NOT NULL,
        streakDays INTEGER NOT NULL,
        role TEXT NOT NULL,
        preferredLanguage TEXT NOT NULL,
        userGoals TEXT NOT NULL,
        hasConsented INTEGER NOT NULL,
        profileImageUrl TEXT
      )
    ''');

    // 2. Screening Details & Results Table
    await db.execute('''
      CREATE TABLE screening_records (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        imageUrl TEXT,
        condition TEXT NOT NULL,
        confidenceLevel TEXT NOT NULL,
        confidenceScore INTEGER NOT NULL,
        explanation TEXT NOT NULL,
        recommendation TEXT NOT NULL,
        assessmentContext TEXT NOT NULL,
        modelVersion TEXT NOT NULL
      )
    ''');

    // 3. Settings / App Storage Table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS user_profiles');
      await db.execute('DROP TABLE IF EXISTS screening_records');
      await db.execute('DROP TABLE IF EXISTS app_settings');
      await _createDB(db, newVersion);
    }
    if (oldVersion < 3) {
      // Add profileImageUrl column to existing user_profiles table
      try {
        await db.execute('ALTER TABLE user_profiles ADD COLUMN profileImageUrl TEXT');
      } catch (_) {
        // Column may already exist
      }
    }
  }

  // ==========================================
  // 👤 PATIENT / USER PROFILE OPERATIONS
  // ==========================================

  Future<int> saveUserProfile(UserProfile profile) async {
    final db = await instance.database;
    final map = profile.toMap();
    map['wearsGlasses'] = profile.wearsGlasses ? 1 : 0;
    map['familyHistory'] = profile.familyHistory ? 1 : 0;
    map['hasConsented'] = profile.hasConsented ? 1 : 0;
    map['commonSymptoms'] = jsonEncode(profile.commonSymptoms);
    map['userGoals'] = jsonEncode(profile.userGoals);

    return await db.insert(
      'user_profiles',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToUserProfile(maps.first);
    }
    return null;
  }

  Future<List<UserProfile>> searchPatients(String searchQuery) async {
    final db = await instance.database;
    final maps = await db.query(
      'user_profiles',
      where: 'name LIKE ?',
      whereArgs: ['%$searchQuery%'],
    );

    return maps.map((map) => _mapToUserProfile(map)).toList();
  }

  Future<List<UserProfile>> getAllUserProfiles() async {
    final db = await instance.database;
    final maps = await db.query('user_profiles');
    return maps.map((map) => _mapToUserProfile(map)).toList();
  }

  Future<int> deleteUserProfile(String id) async {
    final db = await instance.database;
    return await db.delete('user_profiles', where: 'id = ?', whereArgs: [id]);
  }

  UserProfile _mapToUserProfile(Map<String, dynamic> map) {
    final mutableMap = Map<String, dynamic>.from(map);
    mutableMap['wearsGlasses'] = map['wearsGlasses'] == 1;
    mutableMap['familyHistory'] = map['familyHistory'] == 1;
    mutableMap['hasConsented'] = map['hasConsented'] == 1;
    mutableMap['commonSymptoms'] = map['commonSymptoms'] is String
        ? jsonDecode(map['commonSymptoms'])
        : map['commonSymptoms'];
    mutableMap['userGoals'] = map['userGoals'] is String
        ? jsonDecode(map['userGoals'])
        : map['userGoals'];

    return UserProfile.fromMap(mutableMap, mutableMap['id'] as String);
  }

  // ==========================================
  // 📝 SCREENING RECORDS & HISTORY OPERATIONS
  // ==========================================

  Future<int> insertScreeningRecord(ScreeningRecord record) async {
    final db = await instance.database;
    final map = record.toMap();
    map['assessmentContext'] = jsonEncode(map['assessmentContext']);

    return await db.insert(
      'screening_records',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScreeningRecord>> getAllScreeningRecords() async {
    final db = await instance.database;
    final maps = await db.query('screening_records', orderBy: 'date DESC');

    return maps.map((map) => _mapToScreeningRecord(map)).toList();
  }

  Future<List<ScreeningRecord>> searchScreeningsByCondition(String query) async {
    final db = await instance.database;
    final maps = await db.query(
      'screening_records',
      where: 'condition LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date DESC',
    );

    return maps.map((map) => _mapToScreeningRecord(map)).toList();
  }

  Future<ScreeningRecord?> getScreeningRecordById(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'screening_records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToScreeningRecord(maps.first);
    }
    return null;
  }

  Future<int> updateScreeningRecord(ScreeningRecord record) async {
    final db = await instance.database;
    final map = record.toMap();
    map['assessmentContext'] = jsonEncode(map['assessmentContext']);

    return await db.update(
      'screening_records',
      map,
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteScreeningRecord(String id) async {
    final db = await instance.database;
    return await db.delete(
      'screening_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAllScreeningRecords() async {
    final db = await instance.database;
    return await db.delete('screening_records');
  }

  ScreeningRecord _mapToScreeningRecord(Map<String, dynamic> map) {
    final mutableMap = Map<String, dynamic>.from(map);
    if (mutableMap['assessmentContext'] is String) {
      mutableMap['assessmentContext'] = jsonDecode(mutableMap['assessmentContext']);
    }
    return ScreeningRecord.fromMap(mutableMap, mutableMap['id'] as String);
  }

  // ==========================================
  // ⚙️ APP SETTINGS (LOCAL STORAGE)
  // ==========================================

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
