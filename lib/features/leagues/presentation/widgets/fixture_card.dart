import 'package:flutter/material.dart';
import '../../../../core/widgets/glass.dart';

class FixtureCard extends StatelessWidget {
  const FixtureCard({
    super.key,
    required this.home,
    required this.away,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.isPlayed = false,
  });

  final String home;
  final String away;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  /// Optional: change text color if match is played
  final bool isPlayed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Glass(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$home vs $away',
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isPlayed ? Colors.grey[400] : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: t.bodySmall?.copyWith(
                          color: isPlayed ? Colors.grey[500] : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
