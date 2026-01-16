/// Represents a running local live session for a match.
///
/// On host device:
/// - [isHost] = true
/// - [liveMatchId] == matchId (for now)
///
/// On viewer device:
/// - [isHost] = false
/// - [liveMatchId] is provided by host / Join screen.
class LiveSession {
  final String liveMatchId;
  final String leagueId;
  final String matchId;
  final bool isHost;

  const LiveSession({
    required this.liveMatchId,
    required this.leagueId,
    required this.matchId,
    required this.isHost,
  });
}
