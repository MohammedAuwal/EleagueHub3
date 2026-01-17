import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';

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

  @override
  void dispose() {
    _matchIdController.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _join() {
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Join Live Match'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 520 : 440,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Glass(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Connect to Host (Wi‑Fi / LAN)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ask the host for their IP + Port (shown on the Host screen). '
                        'Then enter the Live Match ID.',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _hostController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Host IP',
                          hintText: 'e.g. 192.168.1.25',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter host IP'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _portController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Port',
                          hintText: '8765',
                        ),
                        validator: (v) {
                          final p = int.tryParse(v?.trim() ?? '');
                          if (p == null || p <= 0 || p > 65535) {
                            return 'Enter a valid port (1-65535)';
                          }
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
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter a Live Match ID'
                            : null,
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.play_circle_fill, size: 20),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _join();
                            }
                          },
                          label: const Text(
                            'JOIN LIVE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        'Tip: Host must start broadcasting first.\n'
                        'Viewer must be on the same Wi‑Fi / hotspot.',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
