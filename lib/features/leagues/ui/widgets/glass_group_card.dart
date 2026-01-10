import 'package:flutter/material.dart';
import 'dart:ui';

class GlassGroupCard extends StatelessWidget {
  final String title;
  final List<String> teams;

  const GlassGroupCard({super.key, required this.title, required this.teams});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(color: Colors.white10),
              ...teams.map((team) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.shield, size: 16, color: Colors.white38),
                    const SizedBox(width: 10),
                    Text(team, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              )).toList(),
              // Fill remaining slots for visual consistency
              for (int i = 0; i < (4 - teams.length); i++)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text("...", style: TextStyle(color: Colors.white24)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
