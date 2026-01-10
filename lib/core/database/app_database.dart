import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// 1. Teams Table
class Teams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get leagueId => text()();
}

// 2. Matches Table (The engine for fixtures)
class Matches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get leagueId => text()();
  IntColumn get homeTeamId => integer().references(Teams, #id)();
  IntColumn get awayTeamId => integer().references(Teams, #id)();
  IntColumn get homeScore => integer().nullable()();
  IntColumn get awayScore => integer().nullable()();
  DateTimeColumn get matchDate => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// 3. Standings Table (Cached version for offline speed)
class Standings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get leagueId => text()();
  IntColumn get teamId => integer().references(Teams, #id)();
  IntColumn get played => integer().withDefault(const Constant(0))();
  IntColumn get points => integer().withDefault(const Constant(0))();
  IntColumn get goalsFor => integer().withDefault(const Constant(0))();
  IntColumn get goalsAgainst => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [Teams, Matches, Standings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'esportlyic_db');
  }
}
