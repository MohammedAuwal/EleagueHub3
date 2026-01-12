import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../core/routing/league_mode_provider.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/league_switcher.dart';
import '../../../core/widgets/section_header.dart';

final authStateProvider = StateProvider<bool>((ref) => true);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final themeState = ref.watch(themeControllerProvider);
    final currentLeague = ref.watch(leagueModeProvider);

    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 60),

          /// USER CARD
          Glass(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin_User',
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tournament Director',
                        style:
                            t.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                /// THEME TOGGLE
                IconButton(
                  icon: Icon(
                    themeState.mode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Colors.cyanAccent,
                  ),
                  onPressed: () => ref
                      .read(themeControllerProvider.notifier)
                      .toggleTheme(),
                ),

                /// LOGOUT
                IconButton(
                  icon: const Icon(Icons.logout,
                      color: Colors.white70),
                  onPressed: () {
                    ref.read(authStateProvider.notifier).state = false;
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// LEAGUE MODE SWITCHER (APP STANDARD)
          const LeagueSwitcher(),

          const SizedBox(height: 24),

          /// STATS
          /// Fixed: Using positional argument for title
          const SectionHeader('League Overview'),

          const SizedBox(height: 12),

          Glass(
            child: Row(
              children: [
                const Expanded(
                  child: _Stat(label: 'Active', value: '2'),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _Stat(label: 'Teams', value: '16'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Stat(
                    label: 'Format',
                    value: currentLeague.name
                        .toUpperCase()
                        .replaceAll('CLASSIC', 'CL')
                        .replaceAll('SWISS', 'SW'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Glass(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              value,
              style: t.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: t.bodySmall?.copyWith(color: Colors.white60),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
