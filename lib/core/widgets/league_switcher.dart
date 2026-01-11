import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routing/league_mode_provider.dart';
import 'glass.dart';

class LeagueSwitcher extends ConsumerWidget {
  const LeagueSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentMode = ref.watch(leagueModeProvider);

    return Glass(
      padding: const EdgeInsets.all(6),
      borderRadius: 14,
      child: Row(
        children: LeagueType.values.map((type) {
          final isSelected = currentMode == type;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ref.read(leagueModeProvider.notifier).state = type;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withOpacity(0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(
                          color: colorScheme.primary.withOpacity(0.6),
                          width: 1,
                        )
                      : null,
                ),
                child: Text(
                  _label(type),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.55),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(LeagueType type) {
    switch (type) {
      case LeagueType.classic:
        return 'CLASSIC';
      case LeagueType.uclClassic:
        return 'UCL';
      case LeagueType.uclSwiss:
        return 'SWISS';
    }
  }
}
