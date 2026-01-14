import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/section_header.dart';
import '../domain/standings/standings.dart';
import '../models/league_format.dart';
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
    // 1) Load the league to know which format we're dealing with.
    final leagueAsync = ref.watch(leagueProvider(id));

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader('League Standings'),
                    const SizedBox(height: 12),
                    // 2) Inside the glass card, show content based on league format.
                    Expanded(
                      child: leagueAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.cyanAccent,
                          ),
                        ),
                        error: (error, stack) => Center(
                          child: Text(
                            'Failed to load league.\n${error.toString()}',
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        data: (league) {
                          switch (league.format) {
                            case LeagueFormat.uclGroup:
                              // UCL Group: one table per group.
                              final groupedAsync = ref.watch(
                                leagueGroupedStandingsProvider(id),
                              );
                              return groupedAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.cyanAccent,
                                  ),
                                ),
                                error: (error, stack) => Center(
                                  child: Text(
                                    'Failed to load group standings.\n${error.toString()}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                data: (groupMap) {
                                  if (groupMap.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No group results yet.\n'
                                        'Standings will appear after group matches are played.',
                                        style: TextStyle(
                                          color: Colors.white54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  // Order groups by name: Group A, Group B, ...
                                  final groupKeys = groupMap.keys.toList()
                                    ..sort();

                                  return ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    itemCount: groupKeys.length,
                                    itemBuilder: (context, index) {
                                      final groupId = groupKeys[index];
                                      final rows = groupMap[groupId] ??
                                          const <StandingsRow>[];

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: index ==
                                                  groupKeys.length - 1
                                              ? 0
                                              : 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: Text(
                                                groupId,
                                                style: const TextStyle(
                                                  color: Colors.cyanAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            StandingsTable(rows: rows),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );

                            case LeagueFormat.uclSwiss:
                              // UCL Swiss: single global table + Swiss phase round indicator.
                              final standingsAsync =
                                  ref.watch(leagueStandingsProvider(id));
                              return standingsAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.cyanAccent,
                                  ),
                                ),
                                error: (error, stack) => Center(
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
                                    // Even if no results yet, show Swiss phase info.
                                    return FutureBuilder<int>(
                                      future: _getSwissCurrentRound(ref, id),
                                      builder: (context, snapshot) {
                                        final current =
                                            snapshot.data ?? 0;
                                        final total =
                                            league.settings.swissRounds;

                                        final label = current == 0
                                            ? 'Swiss phase: no rounds yet (max $total rounds)'
                                            : 'Swiss phase: Round $current of $total';

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              label,
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Expanded(
                                              child: Center(
                                                child: Text(
                                                  'No results yet.\n'
                                                  'Standings will appear here after matches are played.',
                                                  style: TextStyle(
                                                    color: Colors.white54,
                                                  ),
                                                  textAlign:
                                                      TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }

                                  return FutureBuilder<int>(
                                    future:
                                        _getSwissCurrentRound(ref, id),
                                    builder: (context, snapshot) {
                                      final current = snapshot.data ?? 0;
                                      final total =
                                          league.settings.swissRounds;

                                      final label = current == 0
                                          ? 'Swiss phase: no rounds yet (max $total rounds)'
                                          : 'Swiss phase: Round $current of $total';

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            label,
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: StandingsTable(
                                              rows: rows,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );

                            case LeagueFormat.classic:
                            default:
                              // Classic: single global standings table.
                              final standingsAsync =
                                  ref.watch(leagueStandingsProvider(id));
                              return standingsAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.cyanAccent,
                                  ),
                                ),
                                error: (error, stack) => Center(
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
                                    return const Center(
                                      child: Text(
                                        'No results yet.\n'
                                        'Standings will appear here after matches are played.',
                                        style: TextStyle(
                                          color: Colors.white54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }
                                  return StandingsTable(rows: rows);
                                },
                              );
                          }
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

/// Helper to compute the highest Swiss round that has been generated so far
/// (based purely on existing matches).
Future<int> _getSwissCurrentRound(WidgetRef ref, String leagueId) async {
  final repo = ref.read(localLeaguesRepositoryProvider);
  final allMatches = await repo.getMatches(leagueId);
  if (allMatches.isEmpty) return 0;
  return allMatches
      .map((m) => m.roundNumber)
      .reduce((a, b) => a > b ? a : b);
}
