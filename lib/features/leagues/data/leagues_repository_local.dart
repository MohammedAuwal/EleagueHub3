import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for debugPrint
import '../../../core/persistence/prefs_service.dart';
import '../models/league.dart';
import '../models/team.dart';
import '../models/fixture_match.dart';

/// Repository responsible for local persistence of League data.
/// Uses SharedPreferences via the PreferencesService.
class LocalLeaguesRepository {
  final PreferencesService _prefs;

  LocalLeaguesRepository(this._prefs);

  // Storage keys
  static const String _leaguesKey = 'stored_leagues';
  static const String _teamsKey = 'stored_teams_';
  static const String _matchesKey = 'stored_matches_';

  /// Fetches all leagues stored locally.
  /// Returns an empty list if no data is found or if decoding fails.
  Future<List<League>> listLeagues() async {
    final String? data = _prefs.getString(_leaguesKey);
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      // We use fromRemoteMap because it matches the JSON structure used in toJson
      return decoded.map((item) => League.fromRemoteMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error decoding leagues: $e');
      return [];
    }
  }

  /// Finds a specific league by its unique ID.
  /// Returns null if the league does not exist.
  Future<League?> getLeagueById(String leagueId) async {
    final leagues = await listLeagues();
    try {
      return leagues.firstWhere((l) => l.id == leagueId);
    } catch (_) {
      return null;
    }
  }

  /// Saves a league or updates it if the ID already exists in the list.
  Future<void> saveLeague(League league) async {
    final List<League> current = await listLeagues();
    final index = current.indexWhere((l) => l.id == league.id);
    
    if (index != -1) {
      current[index] = league;
    } else {
      current.add(league);
    }
    
    // Convert the entire list to JSON for storage
    final String encoded = jsonEncode(current.map((l) => l.toJson()).toList());
    await _prefs.setString(_leaguesKey, encoded);
  }

  /// Stores the list of teams for a specific league.
  Future<void> saveTeams(String leagueId, List<Team> teams) async {
    final String encoded = jsonEncode(teams.map((t) => t.toRemoteMap()).toList());
    await _prefs.setString('$_teamsKey$leagueId', encoded);
  }

  /// Retrieves teams associated with a specific league ID.
  Future<List<Team>> getTeams(String leagueId) async {
    final String? data = _prefs.getString('$_teamsKey$leagueId');
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((t) => Team.fromRemoteMap(t as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error decoding teams for $leagueId: $e');
      return [];
    }
  }

  /// Retrieves all matches (fixtures) for a specific league.
  Future<List<FixtureMatch>> getMatches(String leagueId) async {
    final String? data = _prefs.getString('$_matchesKey$leagueId');
    if (data == null) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded
          .map((m) => FixtureMatch.fromJson(m as Map<String, dynamic>))
          .toList()
          .cast<FixtureMatch>();
    } catch (e) {
      debugPrint('Error decoding matches for $leagueId: $e');
      return [];
    }
  }

  /// Saves or updates matches for a league. 
  /// Uses a Map to ensure match IDs remain unique and updates existing ones.
  Future<void> saveMatches(String leagueId, List<FixtureMatch> matches) async {
    final List<FixtureMatch> existing = await getMatches(leagueId);
    final Map<String, FixtureMatch> matchMap = {for (var m in existing) m.id: m};
    
    for (var m in matches) {
      matchMap[m.id] = m;
    }

    final String encoded = jsonEncode(matchMap.values.map((m) => m.toJson()).toList());
    await _prefs.setString('$_matchesKey$leagueId', encoded);
  }
}
