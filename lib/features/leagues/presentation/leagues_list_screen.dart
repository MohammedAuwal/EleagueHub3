import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass.dart';
import '../data/leagues_repository_mock.dart';

class LeaguesListScreen extends StatefulWidget {
  const LeaguesListScreen({super.key});
  @override
  State<LeaguesListScreen> createState() => _LeaguesListScreenState();
}

class _LeaguesListScreenState extends State<LeaguesListScreen> {
  final _repo = LeaguesRepositoryMock();
  final _search = TextEditingController();
  bool _onlyPublic = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leagues = _repo.listLeagues();
    final q = _search.text.trim().toLowerCase();
    final filtered = leagues.where((l) {
      if (_onlyPublic && l.isPrivate) return false;
      if (q.isEmpty) return true;
      return l.name.toLowerCase().contains(q) || l.id.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _search,
                label: 'Search',
                hint: 'League name or ID',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Glass(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Public'),
                  Switch(
                    value: _onlyPublic,
                    onChanged: (v) => setState(() => _onlyPublic = v),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.push('/leagues/create'),
                icon: const Icon(Icons.add),
                label: const Text('Create League'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showJoinByIdDialog(context),
                icon: const Icon(Icons.vpn_key_outlined),
                label: const Text('Join by ID'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const EmptyState(title: 'No leagues found', message: 'Try a different search.')
        else
          ...filtered.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Glass(
              child: InkWell(
                onTap: () => context.push('/leagues/${l.id}'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _LeagueAvatar(isPrivate: l.isPrivate),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Wrap(
                              spacing: 8,
                              children: [
                                _pill(context, l.id),
                                _pill(context, l.format),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          )),
      ],
    );
  }

  static Widget _pill(BuildContext context, String text) {
    final c = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: c.withOpacity(0.12),
        border: Border.all(color: c.withOpacity(0.22)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }

  Future<void> _showJoinByIdDialog(BuildContext context) async {
    // Standard Dialog Implementation
  }
}

class _LeagueAvatar extends StatelessWidget {
  final bool isPrivate;
  const _LeagueAvatar({required this.isPrivate});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: c.withOpacity(0.2),
      ),
      child: Icon(isPrivate ? Icons.lock : Icons.public, color: c),
    );
  }
}
