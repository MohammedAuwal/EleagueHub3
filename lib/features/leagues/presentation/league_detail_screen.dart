import 'package:flutter/material.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';

class LeagueDetailScreen extends StatelessWidget {
  const LeagueDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('League Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekend Pro League',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Round-robin • Proof required • Auto-standings',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _pill(context, 'Public', c),
                    const SizedBox(width: 8),
                    _pill(context, '20 Players', c),
                    const SizedBox(width: 8),
                    _pill(context, 'Season 1', c),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Fixture',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('PlayerOne vs BlueStorm'),
                    Text(
                      'Starts in 02:18:33',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: c.withOpacity(0.12),
        border: Border.all(color: c.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w800, color: c),
      ),
    );
  }
}
