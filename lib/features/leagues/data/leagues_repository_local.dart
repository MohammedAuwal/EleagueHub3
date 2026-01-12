import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/league.dart';
import '../models/team.dart';

class LocalLeaguesRepository {
  static const String _leaguesKey = 'stored_leagues';
  static const String _teamsKey = 'stored_teams_';

  // Get all leagues saved on the phone
  Future<List<League>> listLeagues() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedLeagues = prefs.getStringList(_leaguesKey) ?? [];
    return encodedLeagues
        .map((item) => League.fromJson(jsonDecode(item)))
        .toList();
  }

  // Save a new league created via the wizard
  Future<void> saveLeague(League league) async {
    final prefs = await SharedPreferences.getInstance();
    final List<League> current = await listLeagues();
    
    // Remove if exists (update) and add new
    current.removeWhere((l) => l.id == league.id);
    current.add(league);

    final List<String> encoded = current.map((l) => jsonEncode(l.toJson())).toList();
    await prefs.setStringList(_leaguesKey, encoded);
  }

  // Save teams added manually
  Future<void> saveTeams(String leagueId, List<Team> teams) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded = teams.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('$_teamsKey$leagueId', encoded);
  }

  Future<List<Team>> getTeams(String leagueId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded = prefs.getStringList('$_teamsKey$leagueId') ?? [];
    return encoded.map((t) => Team.fromJson(jsonDecode(t))).toList();
  }
}
