/// Represents a team within a specific league in eSportlyic.
/// 
/// This model stores the team name and links it to a parent league 
/// using the leagueId. It also includes synchronization metadata 
/// to ensure data consistency across devices.
class Team {
  final String id;
  final String leagueId; // Links this team to its parent Classic or UCL league
  final String name;

  /// Local + remote sync metadata (Last Write Wins)
  final int updatedAtMs;
  final int version;

  const Team({
    required this.id,
    required this.leagueId,
    required this.name,
    required this.updatedAtMs,
    required this.version,
  });

  /// Creates a copy of the Team with updated fields.
  Team copyWith({
    String? id,
    String? leagueId,
    String? name,
    int? updatedAtMs,
    int? version,
  }) {
    return Team(
      id: id ?? this.id,
      leagueId: leagueId ?? this.leagueId,
      name: name ?? this.name,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      version: version ?? this.version,
    );
  }

  /// Converts the Team object into a Map for remote database storage.
  Map<String, dynamic> toRemoteMap() => {
        'id': id,
        'leagueId': leagueId,
        'name': name,
        'updatedAtMs': updatedAtMs,
        'version': version,
      };

  /// Factory to create a Team object from a remote database Map.
  static Team fromRemoteMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as String,
      leagueId: map['leagueId'] as String,
      name: map['name'] as String,
      updatedAtMs: (map['updatedAtMs'] as num).toInt(),
      version: (map['version'] as num).toInt(),
    );
  }
}
