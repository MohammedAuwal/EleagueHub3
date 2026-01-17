import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'local_lan_ip.dart';

const int kLocalLiveDiscoveryPort = 54545;

class DiscoveredHost {
  DiscoveredHost({
    required this.hostIp,
    required this.port,
    required this.matchId,
    required this.lastSeen,
    this.deviceName,
  });

  final String hostIp;
  final int port;
  final String matchId;
  final DateTime lastSeen;
  final String? deviceName;

  String get key => '$hostIp:$port/$matchId';

  DiscoveredHost copyWith({DateTime? lastSeen}) => DiscoveredHost(
        hostIp: hostIp,
        port: port,
        matchId: matchId,
        lastSeen: lastSeen ?? this.lastSeen,
        deviceName: deviceName,
      );
}

/// Host side: broadcasts "I'm hosting matchId on port" on LAN using UDP broadcast.
class LocalLiveDiscoveryBroadcaster {
  LocalLiveDiscoveryBroadcaster({
    required this.matchId,
    required this.port,
    this.deviceName,
  });

  final String matchId;
  final int port;
  final String? deviceName;

  DatagramSocket? _socket;
  Timer? _timer;
  String? _localIp;
  List<InternetAddress> _targets = const [];

  Future<void> start() async {
    if (_socket != null) return;

    _localIp = await LocalLanIp.findLocalIpv4();

    _socket = await DatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _socket!.broadcastEnabled = true;

    _targets = await _computeBroadcastTargets(_localIp);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final payload = jsonEncode({
        'type': 'eleaguehub-live',
        'matchId': matchId,
        'port': port,
        'ip': _localIp,
        'deviceName': deviceName,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });

      final data = utf8.encode(payload);

      // Send to all targets
      for (final t in _targets) {
        try {
          _socket?.send(data, t, kLocalLiveDiscoveryPort);
        } catch (_) {
          // ignore
        }
      }
    });
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;

    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
  }

  Future<List<InternetAddress>> _computeBroadcastTargets(String? localIp) async {
    final targets = <InternetAddress>[];

    // Global broadcast (some routers block this, but it’s worth trying).
    targets.add(InternetAddress('255.255.255.255'));

    // Best-effort /24 broadcast for the current local IP (common home Wi‑Fi).
    if (localIp != null) {
      final parts = localIp.split('.');
      if (parts.length == 4) {
        targets.add(InternetAddress('${parts[0]}.${parts[1]}.${parts[2]}.255'));
      }
    }

    // Also try per-interface /24 broadcasts
    try {
      final ifaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
      for (final iface in ifaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          final p = ip.split('.');
          if (p.length == 4) {
            targets.add(InternetAddress('${p[0]}.${p[1]}.${p[2]}.255'));
          }
        }
      }
    } catch (_) {
      // ignore
    }

    // de-dup
    final seen = <String>{};
    final out = <InternetAddress>[];
    for (final t in targets) {
      if (seen.add(t.address)) out.add(t);
    }
    return out;
  }
}

/// Viewer side: listens for LAN broadcasts and maintains a list of discovered hosts.
class LocalLiveDiscoveryListener {
  DatagramSocket? _socket;
  Timer? _cleanupTimer;

  final ValueNotifier<List<DiscoveredHost>> hosts = ValueNotifier<List<DiscoveredHost>>([]);

  final Map<String, DiscoveredHost> _byKey = {};

  Future<void> start() async {
    if (_socket != null) return;

    _socket = await DatagramSocket.bind(
      InternetAddress.anyIPv4,
      kLocalLiveDiscoveryPort,
      reuseAddress: true,
      reusePort: true,
    );

    _socket!.listen((evt) {
      if (evt != RawSocketEvent.read) return;
      final dg = _socket!.receive();
      if (dg == null) return;

      try {
        final msg = jsonDecode(utf8.decode(dg.data)) as Map<String, dynamic>;
        if (msg['type'] != 'eleaguehub-live') return;

        final matchId = (msg['matchId'] ?? '').toString();
        final port = (msg['port'] as num?)?.toInt() ?? -1;
        if (matchId.isEmpty || port <= 0) return;

        // Prefer declared IP; fallback to packet sender IP
        final ip = (msg['ip'] as String?)?.trim();
        final hostIp = (ip != null && ip.isNotEmpty) ? ip : dg.address.address;

        final deviceName = (msg['deviceName'] as String?)?.trim();

        final now = DateTime.now();
        final h = DiscoveredHost(
          hostIp: hostIp,
          port: port,
          matchId: matchId,
          lastSeen: now,
          deviceName: deviceName?.isEmpty == true ? null : deviceName,
        );

        _byKey[h.key] = h;
        _emit();
      } catch (_) {
        // ignore bad packets
      }
    });

    _cleanupTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final now = DateTime.now();
      _byKey.removeWhere((_, h) => now.difference(h.lastSeen) > const Duration(seconds: 6));
      _emit();
    });
  }

  void _emit() {
    final list = _byKey.values.toList()
      ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    hosts.value = list;
  }

  Future<void> stop() async {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;

    hosts.value = [];
    _byKey.clear();
  }
}
