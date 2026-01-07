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
  });

  final String home;
  final String away;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Glass(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$home vs $away',
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: t.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}
