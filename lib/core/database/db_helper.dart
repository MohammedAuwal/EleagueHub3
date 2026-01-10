import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('esportlyic.db');
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
    // 1. Teams Table
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        leagueId TEXT NOT NULL
      )
    ''');

    // 2. Matches Table (Offline-First Ready)
    await db.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        leagueId TEXT NOT NULL,
        homeTeamId INTEGER NOT NULL,
        awayTeamId INTEGER NOT NULL,
        homeScore INTEGER,
        awayScore INTEGER,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (homeTeamId) REFERENCES teams (id),
        FOREIGN KEY (awayTeamId) REFERENCES teams (id)
      )
    ''');
  }

  // Example: Insert a match (Manual Query)
  Future<int> insertMatch(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('matches', row);
  }
}
