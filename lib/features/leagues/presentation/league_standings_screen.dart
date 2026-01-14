import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/section_header.dart';
import '../domain/standings/standings.dart';
import 'widgets/standings_table.dart';
import 'standings_providers.dart';

class LeagueStandingsScreen extends ConsumerWidget {
  final String id;

  const LeagueStandingsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch standings for this league ID.
    final standingsAsync = ref.watch(leagueStandingsProvider(id));

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader('League Standings'),
                    const SizedBox(height: 12),
                    // Handle loading / error / data states beautifully.
                    standingsAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ),
                      error: (error, stack) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Failed to load standings.\n${error.toString()}',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      data: (rows) {
                        if (rows.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No results yet.\nStandings will appear here after matches are played.',
                              style: TextStyle(
                                color: Colors.white54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        // The actual table – already styled with your Glass and theme colors.
                        return StandingsTable(rows: rows);
                      },
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
