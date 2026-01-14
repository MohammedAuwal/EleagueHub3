import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/prefs_service.dart';
import '../data/leagues_repository_local.dart';
import '../domain/standings/standings.dart';
import '../domain/standings/standings_calculator.dart';

/// Provides a single instance of [LocalLeaguesRepository] using the shared
/// [PreferencesService].
final localLeaguesRepositoryProvider = Provider<LocalLeaguesRepository>((ref) {
  final prefs = ref.watch(prefsServiceProvider);
  return LocalLeaguesRepository(prefs);
});

/// Computes league standings for a given league ID by:
/// - Loading teams and matches from local storage
/// - Running [StandingsCalculator.calculate] over them
final leagueStandingsProvider =
    FutureProvider.family<List<StandingsRow>, String>((ref, leagueId) async {
  final repo = ref.watch(localLeaguesRepositoryProvider);

  final teams = await repo.getTeams(leagueId);
  final matches = await repo.getMatches(leagueId);

  return StandingsCalculator.calculate(
    teams: teams,
    matches: matches,
  );
});
