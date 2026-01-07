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
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _search,
                label: 'Search',
                hint: 'League name or ID',
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
          const Padding(
            padding: EdgeInsets.only(top: 18),
            child: EmptyState(
              title: 'No leagues found',
              message: 'Try a different search or toggle Public.',
            ),
          )
        else
          ...filtered.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Glass(
                child: InkWell(
                  onTap: () => context.push('/leagues/${l.id}'),
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      _LeagueAvatar(isPrivate: l.isPrivate),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _pill(context, l.id),
                                _pill(context, l.format),
                                _pill(context, l.region),
                                _pill(context, '${l.maxTeams} teams'),
                                _pill(context, l.privacy),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  static Widget _pill(BuildContext context, String text) {
    final c = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: c.withOpacity(0.12),
        border: Border.all(color: c.withOpacity(0.22)
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Future<void> _showJoinByIdDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final res = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Join League by ID'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'League ID',
                hintText: 'e.g. L-1001',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter an ID' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(controller.text.trim());
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || res == null) return;

    // Mock: just navigate to detail if it matches mock IDs
    context.push('/leagues/$res');
  }
}

class _LeagueAvatar extends StatelessWidget {
  const _LeagueAvatar({required this.isPrivate});

  final bool isPrivate;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            c.withOpacity(0.85),
            c.withOpacity(0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        isPrivate ? Icons.lock_outline : Icons.public,
        color: Colors.white,
      ),
    );
  }
}
