import '../domain/models.dart';

class LeaguesRepositoryMock {
  // NOTE:
  // This mock now represents a REALISTIC empty league state.
  // No physical league IDs, no physical teams, no auto-filled fixtures.

  /// =========================
  /// LEAGUES
  /// =========================
  List<League> listLeagues() {
    return [
      League(
        id: '', // Generated automatically by backend
        name: 'EleagueHub Open',
        format: 'Swiss',
        privacy: 'Public',
        region: 'EU',
        maxTeams: 32,
        isPrivate: false,
      ),
      League(
        id: '',
        name: 'Night Ops Invitational',
        format: 'UCL Groups+Knockout',
        privacy: 'Private',
        region: 'NA',
        maxTeams: 16,
        isPrivate: true,
      ),
      League(
        id: '',
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
  /// STANDINGS
  /// =========================
  /// Empty until teams join
  List<StandingRow> standings(String leagueId) {
    return [];
  }

  /// =========================
  /// FIXTURES
  /// =========================
  /// Fixtures exist but teams are NOT assigned yet
  List<Fixture> fixtures(String leagueId) {
    final now = DateTime.now();

    return List.generate(10, (i) {
      return Fixture(
        id: 'F-$i', // Temporary local ID
        home: null, // Will be assigned later
        away: null, // Will be assigned later
        scheduledAt: now.add(Duration(days: i)),
        status: 'Scheduled',
        matchId: 'M-$i',
      );
    });
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
    // Backend will:
    // - Generate League ID
    // - Generate QR Code
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  /// =========================
  /// UPLOAD MATCH PROOF
  /// =========================
  Future<void> uploadProofPlaceholder({
    required String leagueId,
    required String matchId,
    required String note,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  /// =========================
  /// ORGANIZER REVIEW
  /// =========================
  Future<void> organizerReviewDecision({
    required String leagueId,
    required String matchId,
    required MatchReviewDecision decision,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }
}
