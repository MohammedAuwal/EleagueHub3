import '../../../core/domain/models.dart';
import '../models/fixture_match.dart';
import '../models/team.dart';
import '../models/team_stats.dart';

class LeaguesRepositoryMock {
  /// =========================
  /// LEAGUES
  /// =========================
  List<League> listLeagues() {
    return [
      League(
        id: 'L-1',
        name: 'EleagueHub Open',
        format: 'Swiss',
        privacy: 'Public',
        region: 'EU',
        maxTeams: 32,
        isPrivate: false,
      ),
      League(
        id: 'L-2',
        name: 'Night Ops Invitational',
        format: 'UCL Groups+Knockout',
        privacy: 'Private',
        region: 'NA',
        maxTeams: 16,
        isPrivate: true,
      ),
      League(
        id: 'L-3',
        name: 'Weekend Round Robin',
        format: 'Round Robin',
        privacy: 'Public',
        region: 'APAC',
        maxTeams: 12,
        isPrivate: false,
      ),
    ];
  }

  /// =========================
  /// TEAMS
  /// =========================
  List<Team> teams(String leagueId) {
    switch (leagueId) {
      case 'L-1':
        return List.generate(8, (i) => Team(
              id: 'T1-$i',
              leagueId: leagueId,
              name: 'Team ${i + 1}',
              updatedAtMs: DateTime.now().millisecondsSinceEpoch,
              version: 1,
            ));
      case 'L-2': // UCL
        return List.generate(16, (i) => Team(
              id: 'T2-$i',
              leagueId: leagueId,
              name: 'Club ${i + 1}',
              updatedAtMs: DateTime.now().millisecondsSinceEpoch,
              version: 1,
            ));
      case 'L-3':
        return List.generate(12, (i) => Team(
              id: 'T3-$i',
              leagueId: leagueId,
              name: 'Side ${i + 1}',
              updatedAtMs: DateTime.now().millisecondsSinceEpoch,
              version: 1,
            ));
      default:
        return [];
    }
  }

  /// =========================
  /// FIXTURES
  /// =========================
  List<FixtureMatch> fixtures(String leagueId) {
    final ts = teams(leagueId);
    if (ts.isEmpty) return [];

    final now = DateTime.now();
    final fixtures = <FixtureMatch>[];

    // Simple round-robin generation
    for (var i = 0; i < ts.length; i++) {
      for (var j = i + 1; j < ts.length; j++) {
        fixtures.add(FixtureMatch(
          id: 'F-$leagueId-$i-$j',
          leagueId: leagueId,
          groupId: leagueId == 'L-2' ? 'Group ${i % 4 + 1}' : null,
          roundNumber: i + 1,
          homeTeamId: ts[i].id,
          awayTeamId: ts[j].id,
          homeScore: null,
          awayScore: null,
          status: MatchStatus.scheduled,
          sortIndex: fixtures.length,
          updatedAtMs: now.millisecondsSinceEpoch,
          version: 1,
        ));
      }
    }
    return fixtures;
  }

  /// =========================
  /// STANDINGS
  /// =========================
  /// Generates TeamStats from fixtures
  List<TeamStats> standings(String leagueId) {
    final ts = teams(leagueId);
    final fx = fixtures(leagueId);

    final Map<String, TeamStats> statsMap = {
      for (var t in ts) t.id: TeamStats.empty(teamId: t.id, leagueId: leagueId)
    };

    for (var match in fx) {
      if (match.isPlayed) {
        statsMap[match.homeTeamId] =
            statsMap[match.homeTeamId]!.applyMatch(
          scored: match.homeScore!,
          conceded: match.awayScore!,
        );
        statsMap[match.awayTeamId] =
            statsMap[match.awayTeamId]!.applyMatch(
          scored: match.awayScore!,
          conceded: match.homeScore!,
        );
      }
    }

    return statsMap.values.toList();
  }

  /// =========================
  /// CREATE LEAGUE
  /// =========================
  Future<void> createLeague({
    required String name,
    required String format,
    required String privacy,
    required String region,
    required int maxTeams,
    required bool forfeitEnabled,
    required int proofDeadlineHours,
    required List<String> tiebreakers,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 450));
  }

  /// =========================
  /// UPLOAD MATCH PROOF
  /// =========================
  Future<void> uploadProofPlaceholder({
    required String leagueId,
    required String matchId,
    required String note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  /// =========================
  /// ORGANIZER REVIEW
  /// =========================
  Future<void> organizerReviewDecision({
    required String leagueId,
    required String matchId,
    required MatchReviewDecision decision,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
  }
}
