import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LiveListScreen extends StatelessWidget {
  const LiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Matches")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/live/join'),
              child: const Text("Join Match"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final matchIdCtrl = TextEditingController();
                final portCtrl = TextEditingController(text: '8765');

                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Host Live Match'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: matchIdCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Live Match ID',
                            hintText: 'e.g. ABC123',
                          ),
                        ),
                        TextField(
                          controller: portCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            hintText: '8765',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Start'),
                      ),
                    ],
                  ),
                );

                if (ok != true) return;

                final matchId = matchIdCtrl.text.trim();
                final port = int.tryParse(portCtrl.text.trim()) ?? 8765;
                if (matchId.isEmpty) return;

                // Opens host view; you can also navigate here from match detail screen in your app.
                if (context.mounted) {
                  context.push(
                    '/live/view/$matchId',
                    extra: {
                      'isHost': true,
                      'port': port,
                    },
                  );
                }
              },
              child: const Text("Host Match"),
            ),
          ],
        ),
      ),
    );
  }
}
