import 'package:flutter/material.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_badge.dart';

class LeaguesListScreen extends StatefulWidget {
  const LeaguesListScreen({super.key});

  @override
  State<LeaguesListScreen> createState() => _LeaguesListScreenState();
}

class _LeaguesListScreenState extends State<LeaguesListScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leagues')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(
            controller: _search,
            label: 'Search leagues',
          ),
          const SizedBox(height: 12),
          const _LeagueTile(
            title: 'Public League: Weekend Pro',
            subtitle: 'Round-robin • 20 players',
            status: 'Open',
          ),
          const SizedBox(height: 10),
          const _LeagueTile(
            title: 'Private League: Friends Cup',
            subtitle: 'UCL Groups + Knockout • 16 players',
            status: 'In Progress',
          ),
        ],
      ),
    );
  }
}

class _LeagueTile extends StatelessWidget {
  const _LeagueTile({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
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
          StatusBadge(status),
        ],
      ),
    );
  }
}
