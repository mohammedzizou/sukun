import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
class DBHelper {
  static Database? _db;
  static final DBHelper instance = DBHelper._internal();

  DBHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'prayer_silence_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    // =========================================
    // USER SETTINGS
    // =========================================
    await db.execute('''
    CREATE TABLE user_settings(
      id INTEGER PRIMARY KEY CHECK(id = 1),
      auto_location INTEGER DEFAULT 1,
      latitude REAL,
      longitude REAL,
      city TEXT,
      country TEXT,
      calculation_method INTEGER DEFAULT 3,
      asr_method INTEGER DEFAULT 0,
      high_latitude_rule INTEGER DEFAULT 0,
      timezone TEXT,
      language TEXT DEFAULT 'en',
      created_at TEXT
    )
    ''');

    // =========================================
    // LOCATION HISTORY
    // =========================================
    await db.execute('''
    CREATE TABLE locations(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      latitude REAL,
      longitude REAL,
      city TEXT,
      country TEXT,
      source TEXT,
      accuracy REAL,
      created_at TEXT
    )
    ''');

    // =========================================
    // PRAYER TIMES CACHE
    // =========================================
    await db.execute('''
    CREATE TABLE prayer_times(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      fajr TEXT,
      sunrise TEXT,
      dhuhr TEXT,
      asr TEXT,
      maghrib TEXT,
      isha TEXT,
      hijri_day INTEGER,
      hijri_month INTEGER,
      hijri_year INTEGER,
      is_ramadan INTEGER DEFAULT 0,
      latitude REAL,
      longitude REAL,
      calculation_method INTEGER,
      created_at TEXT,
      UNIQUE(date, latitude, longitude)
    )
    ''');

    // =========================================
    // USER PRAYER ADJUSTMENTS
    // =========================================
    await db.execute('''
    CREATE TABLE prayer_adjustments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      prayer_name TEXT,
      offset_minutes INTEGER DEFAULT 0,
      created_at TEXT
    )
    ''');

    // =========================================
    // SILENT MODE RULES
    // =========================================
    await db.execute('''
    CREATE TABLE silent_rules(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      prayer_name TEXT,
      enabled INTEGER DEFAULT 1,
      start_offset INTEGER DEFAULT -5,
      end_offset INTEGER DEFAULT 15,
      days_of_week TEXT,
      created_at TEXT,
      updated_at TEXT
    )
    ''');

    // =========================================
    // SILENT MODE LOGS
    // =========================================
    await db.execute('''
    CREATE TABLE silent_logs(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      prayer_name TEXT,
      scheduled_start TEXT,
      scheduled_end TEXT,
      actual_start TEXT,
      actual_end TEXT,
      trigger_type TEXT,
      status TEXT,
      created_at TEXT
    )
    ''');

    // =========================================
    // MOSQUE CACHE
    // =========================================
    await db.execute('''
    CREATE TABLE mosques_cache(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      place_id TEXT,
      name TEXT,
      address TEXT,
      latitude REAL,
      longitude REAL,
      distance REAL,
      cached_at TEXT
    )
    ''');

    // =========================================
    // RAMADAN TRACKER
    // =========================================
    await db.execute('''
    CREATE TABLE ramadan_tracker(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT UNIQUE,
      fasted INTEGER DEFAULT 0,
      taraweeh_prayed INTEGER DEFAULT 0,
      quran_pages INTEGER DEFAULT 0,
      notes TEXT,
      created_at TEXT
    )
    ''');

    // =========================================
    // NOTIFICATION LOG
    // =========================================
    await db.execute('''
    CREATE TABLE notifications_log(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT,
      title TEXT,
      body TEXT,
      scheduled_time TEXT,
      sent_time TEXT,
      opened INTEGER DEFAULT 0,
      opened_at TEXT
    )
    ''');

    // =========================================
    // INDEXES FOR PERFORMANCE
    // =========================================

    await db.execute(
        'CREATE INDEX idx_prayer_date ON prayer_times(date)');
    await db.execute(
        'CREATE INDEX idx_silent_logs_date ON silent_logs(date)');
  }
}