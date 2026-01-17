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
  final _matchIdController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '8765');
  final _formKey = GlobalKey<FormState>();

  final _discovery = LocalLiveDiscoveryListener();
  bool _manual = false;

  @override
  void initState() {
    super.initState();
    _discovery.start();
  }

  @override
  void dispose() {
    _matchIdController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _discovery.stop();
    super.dispose();
  }

  void _joinManual() {
    final matchId = _matchIdController.text.trim();
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? -1;

    if (matchId.isEmpty || host.isEmpty || port <= 0) return;

    context.push(
      '/live/view/$matchId',
      extra: {
        'isHost': false,
        'host': host,
        'port': port,
      },
    );
  }

  void _joinDiscovered(DiscoveredHost h) {
    context.push(
      '/live/view/${h.matchId}',
      extra: {
        'isHost': false,
        'host': h.hostIp,
        'port': h.port,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Join Live Match'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => setState(() => _manual = !_manual),
            child: Text(_manual ? 'Auto' : 'Manual'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 560 : 460),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _manual ? _buildManual(context) : _buildAuto(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuto(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nearby Hosts (Auto‑Discovery)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Make sure you are on the same Wi‑Fi / hotspot as the host. '
            'When the host starts broadcasting, it should appear here.',
            style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),

          ValueListenableBuilder<List<DiscoveredHost>>(
            valueListenable: _discovery.hosts,
            builder: (context, hosts, _) {
              if (hosts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Searching...\n\nIf nothing appears:\n'
                    '• Host must press Start Broadcast\n'
                    '• Both phones same Wi‑Fi/hotspot\n'
                    '• Some routers block broadcast (use Manual in that case)',
                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: hosts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final h = hosts[i];
                  return InkWell(
                    onTap: () => _joinDiscovered(h),
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
                                  'Match: ${h.matchId}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${h.hostIp}:${h.port}${h.deviceName != null ? ' • ${h.deviceName}' : ''}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
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

          const SizedBox(height: 12),
          const Text(
            'Tip: Tap Manual if your Wi‑Fi blocks broadcasts.',
            style: TextStyle(color: Colors.white30, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildManual(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Manual Connect',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _hostController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Host IP',
                hintText: 'e.g. 192.168.1.25',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter host IP' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _portController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Port', hintText: '8765'),
              validator: (v) {
                final p = int.tryParse(v?.trim() ?? '');
                if (p == null || p <= 0 || p > 65535) return 'Enter a valid port';
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _matchIdController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Live Match ID',
                hintText: 'e.g. ABC123 or match-uuid',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a Live Match ID' : null,
            ),

            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) _joinManual();
              },
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('JOIN LIVE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
