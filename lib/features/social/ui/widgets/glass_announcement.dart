import 'package:flutter/material.dart';
import 'dart:ui';

class GlassAnnouncement extends StatelessWidget {
  final String title;
  final String message;
  final String time;

  const GlassAnnouncement({super.key, required this.title, required this.message, required this.time});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 280,
          margin: const EdgeInsets.only(right: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign, color: Colors.cyanAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(message, maxLines: 2, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
