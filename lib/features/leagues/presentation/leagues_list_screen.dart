import 'package:flutter/material.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/status_badge.dart';

class LeaguesListScreen extends StatelessWidget {
  const LeaguesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Leagues'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(
            hintText: 'Search leagues…',
            prefixIcon: Icons.search,
            onChanged: (_) {
              // Hook up filtering later (kept empty so it compiles everywhere).
            },
          ),
          const SizedBox(height: 12),
          const _LeagueCard(
            title: 'Public League: Weekend Pro',
            subtitle: 'Round-robin • 20 players • Region: Global',
            status: 'Open',
          ),
          const SizedBox(height: 12),
          const _LeagueCard(
            title: 'Private League: Friends Cup',
            subtitle: 'UCL Groups + Knockout • 16 players',
            status: 'In Progress',
          ),
          const SizedBox(height: 12),
          const _LeagueCard(
            title: 'Swiss League: Champions Format',
            subtitle: 'Swiss-system • 36 players',
            status: 'Recruiting',
          ),
        ],
      ),
    );
  }
}

class _LeagueCard extends StatelessWidget {
  const _LeagueCard({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Glass(
      child: Row(
        children: [
          const Icon(Icons.shield_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          StatusBadge(status: status),
        ],
      ),
    );
  }
}
