/// Defines whether a match is waiting to be played or finished.
enum MatchStatus { scheduled, played }

/// Extension to handle conversion from integer (database) to MatchStatus.
extension MatchStatusX on MatchStatus {
  static MatchStatus fromInt(int v) => MatchStatus.values[v];
}

/// Represents a single match between two teams in eSportlyic.
/// 
/// This model handles:
/// - Home and Away team assignments.
/// - Scores and match status.
/// - Round numbers and Group IDs (for UCL format).
/// - Sync metadata for offline-first capabilities.
class FixtureMatch {
  final String id;
  final String leagueId;

  /// Group stage only (e.g., UCL Groups). Null for Classic/Domestic leagues.
  final String? groupId;

  /// The round number (e.g., Week 1, Round 2, etc.).
  final int roundNumber;

  final String homeTeamId;
  final String awayTeamId;

  final int? homeScore;
  final int? awayScore;

  final MatchStatus status;

  /// Used for ordering matches within the same round.
  final int sortIndex;

  final int updatedAtMs;
  final int version;

  const FixtureMatch({
    required this.id,
    required this.leagueId,
    required this.groupId,
    required this.roundNumber,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.sortIndex,
    required this.updatedAtMs,
    required this.version,
  });

  /// Quick check to see if a result has been recorded.
  bool get isPlayed => status == MatchStatus.played && homeScore != null && awayScore != null;

  /// Creates a copy of the match with updated fields.
  FixtureMatch copyWith({
    String? id,
    String? leagueId,
    String? groupId,
    int? roundNumber,
    String? homeTeamId,
    String? awayTeamId,
    int? homeScore,
    int? awayScore,
    MatchStatus? status,
    int? sortIndex,
    int? updatedAtMs,
    int? version,
  }) {
    return FixtureMatch(
      id: id ?? this.id,
      leagueId: leagueId ?? this.leagueId,
      groupId: groupId ?? this.groupId,
      roundNumber: roundNumber ?? this.roundNumber,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      status: status ?? this.status,
      sortIndex: sortIndex ?? this.sortIndex,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      version: version ?? this.version,
    );
  }

  /// Converts the match object into a Map for remote database storage.
  Map<String, dynamic> toRemoteMap() => {
        'id': id,
        'leagueId': leagueId,
        'groupId': groupId,
        'roundNumber': roundNumber,
        'homeTeamId': homeTeamId,
        'awayTeamId': awayTeamId,
        'homeScore': homeScore,
        'awayScore': awayScore,
        'status': status.index,
        'sortIndex': sortIndex,
        'updatedAtMs': updatedAtMs,
        'version': version,
      };

  /// Factory to create a FixtureMatch object from a remote database Map.
  static FixtureMatch fromRemoteMap(Map<String, dynamic> map) {
    return FixtureMatch(
      id: map['id'] as String,
      leagueId: map['leagueId'] as String,
      groupId: map['groupId'] as String?,
      roundNumber: (map['roundNumber'] as num).toInt(),
      homeTeamId: map['homeTeamId'] as String,
      awayTeamId: map['awayTeamId'] as String,
      homeScore: (map['homeScore'] as num?)?.toInt(),
      awayScore: (map['awayScore'] as num?)?.toInt(),
      status: MatchStatusX.fromInt((map['status'] as num).toInt()),
      sortIndex: (map['sortIndex'] as num).toInt(),
      updatedAtMs: (map['updatedAtMs'] as num).toInt(),
      version: (map['version'] as num).toInt(),
    );
  }
}
