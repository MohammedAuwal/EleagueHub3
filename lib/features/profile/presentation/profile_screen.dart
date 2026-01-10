import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/routing/league_mode_provider.dart';
import '../../../core/widgets/league_switcher.dart';
import '../../../core/widgets/glass.dart';

final authStateProvider = StateProvider<bool>((ref) => true);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final themeState = ref.watch(themeControllerProvider);
    final currentLeague = ref.watch(leagueModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 60),
          // User Info & Theme Toggle Card
          Glass(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin_User', 
                        style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Tournament Director', 
                        style: t.bodySmall?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    themeState.mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.cyanAccent,
                  ),
                  onPressed: () => ref.read(themeControllerProvider.notifier).toggleLightDark(context),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).state = false;
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout, color: Colors.white70),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          // THE THREE LEAGUES SWITCHER (App Standard)
          const LeagueSwitcher(),
          
          const SizedBox(height: 12),
          // Stats Card
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('League Overview', 
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 16),
                // Removed 'const' from Row children to allow dynamic ref.watch
                Row(
                  children: [
                    const Expanded(child: _Stat(label: 'Active', value: '2')),
                    const SizedBox(width: 12),
                    const Expanded(child: _Stat(label: 'Teams', value: '16')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat(
                        label: 'Format', 
                        value: currentLeague.name.toUpperCase().replaceAll('CLASSIC', 'CL').replaceAll('SWISS', 'SW'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(value, 
              style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(height: 4),
          Text(label, style: t.bodySmall?.copyWith(color: Colors.white60), maxLines: 1),
        ],
      ),
    );
  }
}
