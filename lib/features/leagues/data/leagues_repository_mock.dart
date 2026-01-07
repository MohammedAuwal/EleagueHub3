import 'dart:math';

import '../domain/models.dart';

class LeaguesRepositoryMock {
  // TODO(backend): Replace with real data source (Firebase/Supabase/etc).
  final _rng = Random(4);

  List<League> listLeagues() {
    return [
      League(
        id: 'L-1001',
        name: 'EleagueHub Open',
        format: 'Swiss',
        privacy: 'Public',
        region: 'EU',
        maxTeams: 32,
        isPrivate: false,
      ),
      League(
        id: 'L-2042',
        name: 'Night Ops Invitational',
        format: 'UCL Groups+Knockout',
        privacy: 'Private',
        region: 'NA',
        maxTeams: 16,
        isPrivate: true,
      ),
      League(
        id: 'L-3307',
        name: 'Weekend Round Robin',
        format: 'Round Robin',
        privacy: 'Public',
        region: 'APAC',
        maxTeams: 12,
        isPrivate: false,
      ),
    ];
  }

  List<StandingRow> standings(String leagueId) {
    final teams = [
      'Nova',
      'Apex',
      'Vortex',
      'Zenith',
      'Pulse',
      'Orion',
      'Kairo',
      'Helix'
    ];
    teams.shuffle(_rng);
    return List.generate(8, (i) {
      final p = 7;
      final w = _rng.nextInt(6);
      final d = _rng.nextInt(3);
      final l = (p - w - d).clamp(0, 7);
      final gf = 6 + _rng.nextInt(18);
      final ga = 4 + _rng.nextInt(16);
      final pts = w * 3 + d;
      return StandingRow(
        team: teams[i],
        played: p,
        wins: w,
        draws: d,
        losses: l,
        gf: gf,
        ga: ga,
        points: pts,
      );
    })..sort((a, b) => b.points.compareTo(a.points));
  }

  List<Fixture> fixtures(String leagueId) {
    final now = DateTime.now();
    final statuses = ['Scheduled', 'Pending Proof', 'Under Review', 'Completed'];

    return List.generate(10, (i) {
      final status = statuses[_rng.nextInt(statuses.length)];
      final scheduled = now.add(Duration(hours: (i - 3) * 9));
      return Fixture(
        id: 'F-$leagueId-$i',
        home: ['Nova', 'Apex', 'Vortex', 'Zenith'][_rng.nextInt(4)],
        away: ['Pulse', 'Orion', 'Kairo', 'Helix'][_rng.nextInt(4)],
        scheduledAt: scheduled,
        status: status,
        matchId: 'M-$leagueId-$i',
      );
    });
  }

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
    // TODO(backend): call API
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  Future<void> uploadProofPlaceholder({
    required String leagueId,
    required String matchId,
    required String note,
  }) async {
    // TODO(backend): integrate file picker + upload storage + attach proof to match
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  Future<void> organizerReviewDecision({
    required String leagueId,
    required String matchId,
    required MatchReviewDecision decision,
  }) async {
    // TODO(backend): post decision
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }
}
