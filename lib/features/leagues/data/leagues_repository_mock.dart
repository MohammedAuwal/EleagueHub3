import '../models/league.dart';
import '../../../core/domain/models.dart';
import '../models/fixture_match.dart';
import '../models/team.dart';
import '../models/team_stats.dart';
import '../models/league.dart';
import '../models/league_format.dart';
import '../models/league_settings.dart';

class LeaguesRepositoryMock {
  /// internal cache for joined teams to avoid duplicates and make calls idempotent
  final Map<String, List<Team>> _joinedTeams = {}; // leagueId -> teams

  /// =========================
  /// LEAGUES
  /// =========================
  List<League> listLeagues() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      League(privacy: LeaguePrivacy.public,privacy: LeaguePrivacy.public,
        id: 'L-1',
        code: 'ELEAGUE1',
        name: 'EleagueHub Open',
        format: LeagueFormat.uclSwiss,
        organizerUserId: 'admin-1',
        settings: LeagueSettings.defaultSettings(),
        updatedAtMs: now,
        version: 1,
      ),
      League(privacy: LeaguePrivacy.public,privacy: LeaguePrivacy.public,
        id: 'L-2',
        code: 'UCLGROUP',
        name: 'Night Ops Invitational',
        format: LeagueFormat.uclGroup,
        organizerUserId: 'admin-2',
        settings: LeagueSettings.defaultSettings(),
        updatedAtMs: now,
        version: 1,
      ),
      League(privacy: LeaguePrivacy.public,privacy: LeaguePrivacy.public,
        id: 'L-3',
        code: 'CLASSIC1',
        name: 'Weekend Round Robin',
        format: LeagueFormat.classic,
        organizerUserId: 'admin-3',
        settings: LeagueSettings.defaultSettings(),
        updatedAtMs: now,
        version: 1,
      ),
    ];
  }

  /// =========================
  /// TEAMS (cached / idempotent)
  /// =========================
  List<Team> teams(String leagueId) {
    _joinedTeams.putIfAbsent(leagueId, () {
      switch (leagueId) {
        case 'L-1':
          return List.generate(
            8,
            (i) => Team(
              id: 'T1-$i',
              leagueId: leagueId,
              name: 'Team ${i + 1}',
              updatedAtMs: DateTime.now().millisecondsSinceEpoch,
              version: 1,
            ),
          );
        case 'L-2':
          return List.generate(
            16,
            (i) => Team(
              id: 'T2-$i',
              leagueId: leagueId,
              name: 'Club ${i + 1}',
              updatedAtMs: DateTime.now().millisecondsSinceEpoch,
              version: 1,
            ),
          );
        case 'L-3':
          return List.generate(
            12,
            (i) => Team(
              id: 'T3-$i',
              leagueId: leagueId,
              name: 'Side ${i + 1}',
              updatedAtMs: DateTime.now().millisecondsSinceEpoch,
              version: 1,
            ),
          );
        default:
          return <Team>[];
      }
    });
    return _joinedTeams[leagueId]!;
  }

  /// Adds a participant to a league (idempotent)
  void addParticipant(String leagueId, Team team) {
    _joinedTeams.putIfAbsent(leagueId, () => []);
    final list = _joinedTeams[leagueId]!;
    final idx = list.indexWhere((t) => t.id == team.id);
    if (idx >= 0) {
      list[idx] = team;
    } else {
      list.add(team);
    }
  }

  /// Removes a participant by id
  void removeParticipant(String leagueId, String teamId) {
    _joinedTeams[leagueId]?.removeWhere((t) => t.id == teamId);
  }

  /// =========================
  /// FIXTURES
  /// =========================
  List<FixtureMatch> fixtures(String leagueId) {
    final ts = teams(leagueId);
    if (ts.isEmpty) return [];

    final now = DateTime.now();
    final fixtures = <FixtureMatch>[];

    for (var i = 0; i < ts.length; i++) {
      for (var j = i + 1; j < ts.length; j++) {
        fixtures.add(
          FixtureMatch(
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
          ),
        );
      }
    }
    return fixtures;
  }

  /// =========================
  /// STANDINGS
  /// =========================
  List<TeamStats> standings(String leagueId) {
    final ts = teams(leagueId);
    final fx = fixtures(leagueId);

    final Map<String, TeamStats> statsMap = {
      for (var t in ts)
        t.id: TeamStats.empty(teamId: t.id, leagueId: leagueId)
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
  /// CREATE LEAGUE (ONLINE ONLY)
  /// =========================
  Future<void> createLeague(privacy: LeaguePrivacy.public,privacy: LeaguePrivacy.public,{
    required String name,
    required LeagueFormat format,
    required LeagueSettings settings,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
  }

  /// =========================
  /// UPLOAD MATCH PROOF (ONLINE)
  /// =========================
  Future<void> uploadProofPlaceholder({
    required String leagueId,
    required String matchId,
    required String note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  /// =========================
  /// ORGANIZER REVIEW (ONLINE)
  /// =========================
  Future<void> organizerReviewDecision({
    required String leagueId,
    required String matchId,
    required MatchReviewDecision decision,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
  }
}
