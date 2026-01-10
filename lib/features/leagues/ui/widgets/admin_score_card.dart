import 'package:flutter/material.dart';
import 'dart:ui';

class AdminScoreCard extends StatefulWidget {
  final String homeTeam;
  final String awayTeam;
  final Function(int, int) onSave;

  const AdminScoreCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.onSave,
  });

  @override
  State<AdminScoreCard> createState() => _AdminScoreCardState();
}

class _AdminScoreCardState extends State<AdminScoreCard> {
  int homeScore = 0;
  int awayScore = 0;

  Widget _scoreCounter(String label, int score, Function(int) onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.cyanAccent),
              onPressed: () => score > 0 ? onChanged(score - 1) : null,
            ),
            Text("$score", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.cyanAccent),
              onPressed: () => onChanged(score + 1),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: Text(widget.homeTeam, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  const Text("VS", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w900)),
                  Expanded(child: Text(widget.awayTeam, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _scoreCounter("HOME", homeScore, (val) => setState(() => homeScore = val)),
                  _scoreCounter("AWAY", awayScore, (val) => setState(() => awayScore = val)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => widget.onSave(homeScore, awayScore),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("UPDATE SCORE"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
