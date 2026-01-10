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
    required this.onSave
  });

  @override
  State<AdminScoreCard> createState() => _AdminScoreCardState();
}

class _AdminScoreCardState extends State<AdminScoreCard> {
  final _homeController = TextEditingController();
  final _awayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const Text("ENTER MATCH RESULT", style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTeamInput(widget.homeTeam, _homeController),
                  const Text("VS", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
                  _buildTeamInput(widget.awayTeam, _awayController),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.withOpacity(0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  final h = int.tryParse(_homeController.text) ?? 0;
                  final a = int.tryParse(_awayController.text) ?? 0;
                  widget.onSave(h, a);
                },
                child: const Text("CONFIRM SCORE", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInput(String name, TextEditingController controller) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}
