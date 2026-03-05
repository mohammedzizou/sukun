import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
class DBHelper {
  static Database? _db;
  // Function to get the database instance. If not initialized, it initializes the database.
  Future<Database?> get database async {
    if (_db == null) {
      _db = await intialDb();
      return _db;
    } else {
      return _db;
    }
  }

  // Function to initialize the database with necessary tables and schema.
  Future<Database> intialDb() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'fintechracyuser.db');
    Database mydb = await openDatabase(
      path,
      version: 28,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return mydb;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}
  Future<void> _onCreate(Database db, int version) async {}
}
