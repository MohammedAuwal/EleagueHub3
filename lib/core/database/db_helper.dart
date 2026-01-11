import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  /// Singleton instance
  static final DbHelper instance = DbHelper._init();

  static Database? _database;

  DbHelper._init();

  /// Get database (initialize if null)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('esportlyic.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create all tables
  Future<void> _createDB(Database db, int version) async {
    // =========================
    // TEAMS TABLE
    // =========================
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        leagueId TEXT NOT NULL
      )
    ''');

    // =========================
    // MATCHES TABLE
    // =========================
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

  /// =========================
  /// DATABASE HELPERS
  /// =========================

  /// Insert a team
  Future<int> insertTeam(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('teams', row);
  }

  /// Insert a match
  Future<int> insertMatch(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('matches', row);
  }

  /// Query all teams
  Future<List<Map<String, dynamic>>> getAllTeams() async {
    final db = await instance.database;
    return await db.query('teams');
  }

  /// Query all matches
  Future<List<Map<String, dynamic>>> getAllMatches() async {
    final db = await instance.database;
    return await db.query('matches');
  }

  /// Close database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
