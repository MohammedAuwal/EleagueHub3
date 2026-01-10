import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/glass.dart';

final authStateProvider = StateProvider<bool>((ref) => true);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final themeMode = ref.watch(themeControllerProvider).mode;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 50),
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
                      Text('Admin_User', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Tournament Director', style: t.bodySmall?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                // Merged Theme Toggle
                IconButton(
                  icon: Icon(
                    themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.cyanAccent,
                  ),
                  onPressed: () => ref.read(themeControllerProvider.notifier).toggleLightDark(context),
                ),
                // Logout Button
                IconButton(
                  onPressed: () => ref.read(authStateProvider.notifier).state = false,
                  icon: const Icon(Icons.logout, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('League Stats', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(child: _Stat(label: 'Active', value: '2')),
                    SizedBox(width: 12),
                    Expanded(child: _Stat(label: 'Teams', value: '16')),
                    SizedBox(width: 12),
                    Expanded(child: _Stat(label: 'UCL Mode', value: 'ON')),
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
  const _Stat({required this.label, required this.value});
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
          Text(value, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: t.bodySmall?.copyWith(color: Colors.white60)),
        ],
      ),
    );
  }
}
