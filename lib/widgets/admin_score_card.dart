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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.cyanAccent, size: 28),
              onPressed: () => score > 0 ? onChanged(score - 1) : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$score", 
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.cyanAccent, size: 28),
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
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.homeTeam, 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)
                    )
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("VS", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                  Expanded(
                    child: Text(
                      widget.awayTeam, 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)
                    )
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _scoreCounter("HOME", homeScore, (val) => setState(() => homeScore = val)),
                  _scoreCounter("AWAY", awayScore, (val) => setState(() => awayScore = val)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => widget.onSave(homeScore, awayScore),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Colors.cyanAccent, width: 1),
                    ),
                  ),
                  child: const Text(
                    "UPDATE SCORE", 
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
