import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/preferences_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loading = true;

  bool _enabled = true;
  bool _marketing = false;
  bool _matchReminders = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = ref.read(preferencesServiceProvider);
    final map = await prefs.loadNotificationPrefs();
    if (!mounted) return;
    setState(() {
      _enabled = map['enabled'] ?? true;
      _marketing = map['marketing'] ?? false;
      _matchReminders = map['matchReminders'] ?? true;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = ref.read(preferencesServiceProvider);
    await prefs.saveNotificationPrefs(
      enabled: _enabled,
      marketing: _marketing,
      matchReminders: _matchReminders,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider).mode;

    return GlassScaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Sky Blue')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Deep Navy')),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (s) async {
                    await ref
                        .read(themeControllerProvider.notifier)
                        .setMode(s.first);
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Auto-detects system brightness on first launch. Your choice persists.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                if (_loading)
                  const LinearProgressIndicator()
                else ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enabled'),
                    value: _enabled,
                    onChanged: (v) async {
                      setState(() => _enabled = v);
                      await _save();
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Match reminders'),
                    value: _matchReminders,
                    onChanged: !_enabled
                        ? null
                        : (v) async {
                            setState(() => _matchReminders = v);
                            await _save();
                          },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Marketing'),
                    value: _marketing,
                    onChanged: !_enabled
                        ? null
                        : (v) async {
                            setState(() => _marketing = v);
                            await _save();
                          },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App info',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text('EleagueHub • MVP skeleton'),
                const SizedBox(height: 4),
                Text(
                  'No backend connected. Offline mock data.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
