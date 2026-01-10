import 'dart:convert';

import 'league_format.dart';

/// Configuration for league rules and sync state.
///
/// This class handles how the league logic operates (e.g., group sizes)
/// and tracks the last synchronization time to optimize data pulling.
class LeagueSettings {
  final bool doubleRoundRobin; // default true (Home and Away matches)
  final int groupSize; // default 4 for UCL groups
  final int swissRounds; // default 8

  /// Used by sync to avoid expensive full scans.
  final int lastPulledAtMs;

  const LeagueSettings({
    required this.doubleRoundRobin,
    required this.groupSize,
    required this.swissRounds,
    required this.lastPulledAtMs,
  });

  /// Provides reasonable defaults based on the chosen LeagueFormat.
  factory LeagueSettings.defaultsFor(LeagueFormat format) {
    return const LeagueSettings(
      doubleRoundRobin: true,
      groupSize: 4,
      swissRounds: 8,
      lastPulledAtMs: 0,
    );
  }

  /// Creates a copy of the settings with updated values.
  LeagueSettings copyWith({
    bool? doubleRoundRobin,
    int? groupSize,
    int? swissRounds,
    int? lastPulledAtMs,
  }) {
    return LeagueSettings(
      doubleRoundRobin: doubleRoundRobin ?? this.doubleRoundRobin,
      groupSize: groupSize ?? this.groupSize,
      swissRounds: swissRounds ?? this.swissRounds,
      lastPulledAtMs: lastPulledAtMs ?? this.lastPulledAtMs,
    );
  }

  /// Converts the settings object to a Map for storage/JSON.
  Map<String, dynamic> toMap() => {
        'doubleRoundRobin': doubleRoundRobin,
        'groupSize': groupSize,
        'swissRounds': swissRounds,
        'lastPulledAtMs': lastPulledAtMs,
      };

  /// Creates a settings object from a Map.
  factory LeagueSettings.fromMap(Map<String, dynamic> map) {
    return LeagueSettings(
      doubleRoundRobin: (map['doubleRoundRobin'] as bool?) ?? true,
      groupSize: (map['groupSize'] as num?)?.toInt() ?? 4,
      swissRounds: (map['swissRounds'] as num?)?.toInt() ?? 8,
      lastPulledAtMs: (map['lastPulledAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  /// Encodes the settings to a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Decodes a JSON string into a LeagueSettings object.
  factory LeagueSettings.fromJson(String json) {
    if (json.trim().isEmpty) {
      return const LeagueSettings(
        doubleRoundRobin: true,
        groupSize: 4,
        swissRounds: 8,
        lastPulledAtMs: 0,
      );
    }
    return LeagueSettings.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }
}
