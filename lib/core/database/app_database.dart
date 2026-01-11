import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// =========================
/// TABLES
/// =========================

class Teams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get leagueId => text()();
}

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

class Standings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get leagueId => text()();
  IntColumn get teamId => integer().references(Teams, #id)();
  IntColumn get played => integer().withDefault(const Constant(0))();
  IntColumn get points => integer().withDefault(const Constant(0))();
  IntColumn get goalsFor => integer().withDefault(const Constant(0))();
  IntColumn get goalsAgainst => integer().withDefault(const Constant(0))();
}

/// =========================
/// DATABASE CLASS
/// =========================

@DriftDatabase(tables: [Teams, Matches, Standings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Open Flutter database connection
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      return FlutterQueryExecutor(
        path: 'esportlyic_db.sqlite',
        logStatements: true, // optional: helpful for debugging
      );
    });
  }

  // =========================
  // OPTIONAL CRUD HELPERS
  // =========================

  Future<int> insertTeam(TeamsCompanion team) => into(teams).insert(team);

  Future<int> insertMatch(MatchesCompanion match) => into(matches).insert(match);

  Future<List<Match>> getAllMatches() => select(matches).get();

  Future<List<Team>> getAllTeams() => select(teams).get();
}
