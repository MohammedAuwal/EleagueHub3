import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/local_discovery.dart';

class JoinMatchScreen extends ConsumerStatefulWidget {
  const JoinMatchScreen({super.key});

  @override
  ConsumerState<JoinMatchScreen> createState() => _JoinMatchScreenState();
}

class _JoinMatchScreenState extends ConsumerState<JoinMatchScreen> {
  final _discovery = LocalLiveDiscoveryListener();

  @override
  void initState() {
    super.initState();
    _discovery.start();
  }

  @override
  void dispose() {
    _discovery.stop();
    super.dispose();
  }

  void _joinHost(DiscoveredHost h) {
    context.push(
      '/live/view/${h.matchId}',
      extra: {
        'isHost': false,
        'host': h.hostIp,
        'port': h.port,

        // pass names so LiveView shows team names even without league context
        'homeName': h.homeName,
        'awayName': h.awayName,

        // pass side so viewer can map host to left/right
        'side': liveHostSideToWire(h.side),
      },
    );
  }

  Future<void> _openManual() async {
    final hostCtrl = TextEditingController();
    final portCtrl = TextEditingController(text: '8765');
    final matchIdCtrl = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Glass(
            borderRadius: 20,
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Manual Connect',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hostCtrl,
                  decoration: const InputDecoration(labelText: 'Host IP (e.g. 192.168.1.25)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: portCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Port (default 8765)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: matchIdCtrl,
                  decoration: const InputDecoration(labelText: 'Match ID'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Join'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );

    if (ok != true) return;

    final host = hostCtrl.text.trim();
    final port = int.tryParse(portCtrl.text.trim()) ?? 8765;
    final matchId = matchIdCtrl.text.trim();
    if (host.isEmpty || matchId.isEmpty) return;

    if (!mounted) return;
    context.push(
      '/live/view/$matchId',
      extra: {
        'isHost': false,
        'host': host,
        'port': port,
        'side': 'unknown',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Join Live'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _openManual,
            child: const Text('Manual'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 600 : 500),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Glass(
                borderRadius: 24,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Nearby Matches',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Auto‑Discovery works when you are on the same Wi‑Fi/hotspot as the host.\n'
                      'If nothing appears, tap Manual.',
                      style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ValueListenableBuilder<List<DiscoveredHost>>(
                        valueListenable: _discovery.hosts,
                        builder: (_, hosts, __) {
                          if (hosts.isEmpty) {
                            return const Center(
                              child: Text(
                                'Searching…',
                                style: TextStyle(color: Colors.white54),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: hosts.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final h = hosts[i];
                              final title = (h.homeName != null && h.awayName != null)
                                  ? '${h.homeName} vs ${h.awayName}'
                                  : 'Match ${h.matchId}';
                              final subtitle = '${h.hostIp}:${h.port} • ${liveHostSideToWire(h.side)}';

                              return InkWell(
                                onTap: () => _joinHost(h),
                                child: Glass(
                                  borderRadius: 18,
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.wifi_tethering, color: Colors.cyanAccent),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              subtitle,
                                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
