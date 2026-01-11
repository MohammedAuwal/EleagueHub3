class ParticipantsService {
  // Mock backend: replace with API calls
  final Map<String, List<String>> _data = {};

  Future<List<String>> getParticipants(String leagueId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulate network
    return _data[leagueId] ?? [];
  }

  Future<bool> addParticipant(String leagueId, String id) async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulate network
    _data[leagueId] ??= [];
    if (_data[leagueId]!.contains(id)) return false;
    _data[leagueId]!.add(id);
    return true;
  }

  Future<bool> removeParticipant(String leagueId, String id) async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulate network
    return _data[leagueId]?.remove(id) ?? false;
  }
}
