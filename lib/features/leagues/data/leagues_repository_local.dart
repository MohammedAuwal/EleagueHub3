import 'dart:convert';
import '../../../core/persistence/prefs_service.dart';
import '../models/league.dart';
import '../models/team.dart';
import '../models/fixture_match.dart';

class LocalLeaguesRepository {
  final PrefsService _prefs;

  LocalLeaguesRepository(this._prefs);

  static const String _leaguesKey = 'stored_leagues';
  static const String _teamsKey = 'stored_teams_';
  static const String _matchesKey = 'stored_matches_';

  /// Get all leagues saved locally
  Future<List<League>> listLeagues() async {
    final String? data = _prefs.getString(_leaguesKey);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((item) => League.fromJson(item)).toList();
  }

  /// Save or update a league
  Future<void> saveLeague(League league) async {
    final List<League> current = await listLeagues();
    
    final index = current.indexWhere((l) => l.id == league.id);
    if (index != -1) {
      current[index] = league;
    } else {
      current.add(league);
    }

    final String encoded = jsonEncode(current.map((l) => l.toJson()).toList());
    await _prefs.setString(_leaguesKey, encoded);
  }

  /// Save teams for a specific league
  Future<void> saveTeams(String leagueId, List<Team> teams) async {
    final String encoded = jsonEncode(teams.map((t) => t.toJson()).toList());
    await _prefs.setString('$_teamsKey$leagueId', encoded);
  }

  /// Retrieve teams for a specific league
  Future<List<Team>> getTeams(String leagueId) async {
    final String? data = _prefs.getString('$_teamsKey$leagueId');
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((t) => Team.fromJson(t)).toList();
  }

  /// NEW: Retrieve matches for a specific league
  Future<List<FixtureMatch>> getMatches(String leagueId) async {
    final String? data = _prefs.getString('$_matchesKey$leagueId');
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((m) => FixtureMatch.fromJson(m)).toList();
  }

  /// NEW: Save or update matches for a specific league
  Future<void> saveMatches(String leagueId, List<FixtureMatch> matches) async {
    final List<FixtureMatch> existing = await getMatches(leagueId);
    
    // Use a Map to easily merge updates by ID
    final Map<String, FixtureMatch> matchMap = {
      for (var m in existing) m.id: m
    };
    
    for (var m in matches) {
      matchMap[m.id] = m;
    }

    final String encoded = jsonEncode(matchMap.values.map((m) => m.toJson()).toList());
    await _prefs.setString('$_matchesKey$leagueId', encoded);
  }
}
