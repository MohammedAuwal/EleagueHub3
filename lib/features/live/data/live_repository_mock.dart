import '../domain/models.dart';

class LiveRepositoryMock {
  // TODO(backend): real live session integration (WebSocket / RTC / etc)
  List<LiveMatch> listLive() {
    return [
      LiveMatch(id: 'LM-8891', title: 'Nova vs Apex', viewers: 128, status: 'LIVE'),
      LiveMatch(id: 'LM-5203', title: 'Vortex vs Zenith', viewers: 54, status: 'LIVE'),
      LiveMatch(id: 'LM-1044', title: 'Pulse vs Orion', viewers: 21, status: 'Starting'),
    ];
  }
}
