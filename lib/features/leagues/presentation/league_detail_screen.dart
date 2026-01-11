import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';

class LeagueDetailScreen extends StatelessWidget {
  final String leagueId;

  const LeagueDetailScreen({
    super.key,
    required this.leagueId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('League Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _overviewCard(context, primary),
          const SizedBox(height: 12),
          _quickActions(context),
          const SizedBox(height: 12),
          _nextFixture(context),
        ],
      ),
    );
  }

  /// -------------------------------
  /// League overview
  /// -------------------------------
  Widget _overviewCard(BuildContext context, Color c) {
    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'League ID: $leagueId',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Round-robin • Proof required • Auto standings',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('Public', c),
              _pill('20 Players', c),
              _pill('Season 1', c),
              _pill('Classic League', c),
            ],
          ),
        ],
      ),
    );
  }

  /// -------------------------------
  /// Quick actions
  /// -------------------------------
  Widget _quickActions(BuildContext context) {
    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Fixtures'),
                  onPressed: () =>
                      context.push('/leagues/$leagueId/fixtures'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('Standings'),
                  onPressed: () =>
                      context.push('/leagues/$leagueId/standings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// -------------------------------
  /// Next fixture
  /// -------------------------------
  Widget _nextFixture(BuildContext context) {
    return Glass(
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(
                '/leagues/$leagueId/matches/current',
              ),
              child: const Text('View match'),
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------------------
  /// Pill widget
  /// -------------------------------
  Widget _pill(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: c.withOpacity(0.12),
        border: Border.all(color: c.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: c,
          fontSize: 12,
        ),
      ),
    );
  }
}
