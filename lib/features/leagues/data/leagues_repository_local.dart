import 'dart:convert';
import '../../../core/persistence/prefs_service.dart';
import '../models/league.dart';
import '../models/team.dart';

class LocalLeaguesRepository {
  final PreferencesService _prefs;

  LocalLeaguesRepository(this._prefs);

  static const String _leaguesKey = 'stored_leagues';
  static const String _teamsKey = 'stored_teams_';

  /// Get all leagues saved locally
  Future<List<League>> listLeagues() async {
    final List<String> encodedLeagues = _prefs.getStringList(_leaguesKey);
    return encodedLeagues
        .map((item) => League.fromJson(jsonDecode(item)))
        .toList();
  }

  /// Save or update a league
  Future<void> saveLeague(League league) async {
    final List<League> current = await listLeagues();
    
    // Update if existing, otherwise add
    final index = current.indexWhere((l) => l.id == league.id);
    if (index != -1) {
      current[index] = league;
    } else {
      current.add(league);
    }

    final List<String> encoded = current.map((l) => jsonEncode(l.toJson())).toList();
    await _prefs.setStringList(_leaguesKey, encoded);
  }

  /// Save teams for a specific league
  Future<void> saveTeams(String leagueId, List<Team> teams) async {
    final List<String> encoded = teams.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList('$_teamsKey$leagueId', encoded);
  }

  /// Retrieve teams for a specific league
  Future<List<Team>> getTeams(String leagueId) async {
    final List<String> encoded = _prefs.getStringList('$_teamsKey$leagueId');
    return encoded.map((t) => Team.fromJson(jsonDecode(t))).toList();
  }
}
