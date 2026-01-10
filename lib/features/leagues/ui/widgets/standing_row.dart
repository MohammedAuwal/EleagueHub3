import 'package:flutter/material.dart';

class StandingRow extends StatelessWidget {
  final int rank;
  final String teamName;
  final int points;
  final int gd;
  final bool isQualified;

  const StandingRow({
    super.key,
    required this.rank,
    required this.teamName,
    required this.points,
    required this.gd,
    this.isQualified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isQualified ? Colors.cyanAccent.withOpacity(0.05) : Colors.transparent,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text("$rank", style: TextStyle(
              color: isQualified ? Colors.cyanAccent : Colors.white60,
              fontWeight: isQualified ? FontWeight.bold : FontWeight.normal,
            )),
          ),
          Expanded(
            child: Text(teamName, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
          SizedBox(width: 40, child: Text("$gd", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70))),
          SizedBox(width: 40, child: Text("$points", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
