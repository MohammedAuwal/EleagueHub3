import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/glass.dart';
import '../domain/standings/standings.dart';
import 'widgets/standings_table.dart';

class LeagueStandingsScreen extends ConsumerWidget {
  final String id;

  const LeagueStandingsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace this placeholder with your real Riverpod provider,
    // e.g. final rows = ref.watch(leagueStandingsProvider(id)).value ?? [];
    const List<StandingsRow> rows = [];

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
                  // StandingsTable expects a List<StandingsRow> via `rows:`
                  rows: rows,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
