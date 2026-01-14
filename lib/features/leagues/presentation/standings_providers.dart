import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/prefs_service.dart';
import '../data/leagues_repository_local.dart';
import '../domain/standings/standings.dart';
import '../domain/standings/standings_calculator.dart';
import '../models/league.dart';

/// Provides a single instance of [LocalLeaguesRepository] using the shared
/// [PreferencesService].
final localLeaguesRepositoryProvider =
    Provider<LocalLeaguesRepository>((ref) {
  final prefs = ref.watch(prefsServiceProvider);
  return LocalLeaguesRepository(prefs);
});

/// Loads a League by ID (to access format, settings, etc.).
final leagueProvider = FutureProvider.family<League, String>(
  (ref, leagueId) async {
    final repo = ref.watch(localLeaguesRepositoryProvider);
    final league = await repo.getLeagueById(leagueId);
    if (league == null) {
      throw Exception('League not found');
    }
    return league;
  },
);

/// Computes GLOBAL league standings for a given league ID by:
/// - Loading all teams + all matches from local storage
/// - Running [StandingsCalculator.calculate] over them
///
/// Used for:
/// - Classic leagues
/// - Swiss leagues (single-table view)
final leagueStandingsProvider =
    FutureProvider.family<List<StandingsRow>, String>(
  (ref, leagueId) async {
    final repo = ref.watch(localLeaguesRepositoryProvider);

    final teams = await repo.getTeams(leagueId);
    final matches = await repo.getMatches(leagueId);

    return StandingsCalculator.calculate(
      teams: teams,
      matches: matches,
    );
  },
);

/// Computes GROUPED standings for UCL-style group stages.
///
/// Returns a map of:
///   groupId (e.g. "Group A") -> List<StandingsRow> for that group
///
/// Implementation:
/// - Load all teams and matches
/// - Partition matches by [FixtureMatch.groupId]
/// - For each groupId, find the participating teams and run StandingsCalculator
final leagueGroupedStandingsProvider =
    FutureProvider.family<Map<String, List<StandingsRow>>, String>(
  (ref, leagueId) async {
    final repo = ref.watch(localLeaguesRepositoryProvider);

    final allTeams = await repo.getTeams(leagueId);
    final allMatches = await repo.getMatches(leagueId);

    // Detect all non-empty groupIds from matches.
    final groupIds = allMatches
        .map((m) => m.groupId)
        .whereType<String>()
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toSet();

    final result = <String, List<StandingsRow>>{};

    for (final groupId in groupIds) {
      final groupMatches = allMatches
          .where((m) => m.groupId == groupId)
          .toList();

      if (groupMatches.isEmpty) continue;

      // Determine which teams appear in this group.
      final groupTeamIds = <String>{};
      for (final m in groupMatches) {
        groupTeamIds.add(m.homeTeamId);
        groupTeamIds.add(m.awayTeamId);
      }

      final groupTeams = allTeams
          .where((t) => groupTeamIds.contains(t.id))
          .toList();

      if (groupTeams.isEmpty) continue;

      final standings = StandingsCalculator.calculate(
        teams: groupTeams,
        matches: groupMatches,
      );

      result[groupId] = standings;
    }

    return result;
  },
);
