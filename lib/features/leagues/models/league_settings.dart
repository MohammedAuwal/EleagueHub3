import 'dart:convert';
import 'league_format.dart';

class LeagueSettings {
  final bool doubleRoundRobin;
  final int groupSize;
  final int swissRounds;
  final int lastPulledAtMs;

  const LeagueSettings({
    required this.doubleRoundRobin,
    required this.groupSize,
    required this.swissRounds,
    required this.lastPulledAtMs,
  });

  /// Your production defaults logic
  factory LeagueSettings.defaultsFor(LeagueFormat format) {
    return const LeagueSettings(
      doubleRoundRobin: true,
      groupSize: 4,
      swissRounds: 8,
      lastPulledAtMs: 0,
    );
  }

  /// Alias to fix the repository error while keeping your logic
  factory LeagueSettings.defaultSettings() {
    return const LeagueSettings(
      doubleRoundRobin: true,
      groupSize: 4,
      swissRounds: 8,
      lastPulledAtMs: 0,
    );
  }

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

  Map<String, dynamic> toMap() => {
        'doubleRoundRobin': doubleRoundRobin,
        'groupSize': groupSize,
        'swissRounds': swissRounds,
        'lastPulledAtMs': lastPulledAtMs,
      };

  factory LeagueSettings.fromMap(Map<String, dynamic> map) {
    return LeagueSettings(
      doubleRoundRobin: (map['doubleRoundRobin'] as bool?) ?? true,
      groupSize: (map['groupSize'] as num?)?.toInt() ?? 4,
      swissRounds: (map['swissRounds'] as num?)?.toInt() ?? 8,
      lastPulledAtMs: (map['lastPulledAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  String toJson() => jsonEncode(toMap());

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
