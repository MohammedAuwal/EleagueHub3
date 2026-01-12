import 'league_format.dart';
/// Defines whether a match is waiting to be played or finished.
    return MatchStatus.values[v];
  }
}

/// Represents a single match fixture in eSportlyic.
///
/// Supports:
/// - Classic Round Robin
/// - UCL Group Stage
/// - UCL Swiss Model
/// - Offline-first syncing
class FixtureMatch {
  final String id;
  final String leagueId;

  /// Used only for UCL Group Stage (e.g. Group A, Group B).
  /// Null for Classic & Swiss formats.
  final String? groupId;

  /// Round number (Week 1, Matchday 2, etc.)
  final int roundNumber;

  final String homeTeamId;
  final String awayTeamId;

  final int? homeScore;
  final int? awayScore;

  final MatchStatus status;

  /// Sorting within the same round (UI consistency)
  final int sortIndex;

  /// Offline sync metadata
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

  /// True only when the match has a valid recorded result.
  bool get isPlayed =>
      status == MatchStatus.completed &&
      homeScore != null &&
      awayScore != null;

  /// Safe goal values (used by standings engine)
  int get safeHomeScore => homeScore ?? 0;
  int get safeAwayScore => awayScore ?? 0;

  /// Creates a new instance with updated fields.
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

  /// Serialize for remote storage (Firebase / REST / Supabase).
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

  /// Deserialize from remote storage.
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
