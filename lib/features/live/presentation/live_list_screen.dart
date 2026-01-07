import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass.dart';
import '../data/live_repository_mock.dart';

class LiveListScreen extends StatelessWidget {
  const LiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = LiveRepositoryMock();
    final items = repo.listLive();

    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.push('/live/join'),
                icon: const Icon(Icons.confirmation_number_outlined),
                label: const Text('Join via Match ID'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const EmptyState(
            title: 'No live matches',
            message: 'Check back later. Live sessions will appear here.',
          )
        else
          ...items.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Glass(
                child: InkWell(
                  onTap: () => context.push('/live/view/${m.id}'),
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_tethering,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text('${m.status} • ${m.viewers} watching',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
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
}
