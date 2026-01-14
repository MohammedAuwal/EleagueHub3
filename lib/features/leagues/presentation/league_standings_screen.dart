import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/glass.dart';
import 'widgets/standings_table.dart';

class LeagueStandingsScreen extends ConsumerWidget {
  final String id;

  const LeagueStandingsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Standings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Glass(
                padding: const EdgeInsets.all(16),
                child: StandingsTable(
                  leagueId: id,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
