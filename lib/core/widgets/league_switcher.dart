import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Defining the enum and provider here ensures they are always found
enum LeagueType { classic, uclClassic, uclSwiss }

final leagueModeProvider = StateProvider<LeagueType>((ref) => LeagueType.classic);

class LeagueSwitcher extends ConsumerWidget {
  const LeagueSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(leagueModeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: LeagueType.values.map((type) {
          final isSelected = currentMode == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(leagueModeProvider.notifier).state = type,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.cyanAccent.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected ? Border.all(color: Colors.cyanAccent, width: 1) : null,
                ),
                child: Text(
                  _getLabel(type),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.cyanAccent : Colors.white60,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(LeagueType type) {
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
