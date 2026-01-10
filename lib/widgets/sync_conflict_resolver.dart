import 'package:flutter/material.dart';
import 'dart:ui';

class SyncConflictResolver extends StatelessWidget {
  final Map<String, dynamic> localData;
  final Map<String, dynamic> cloudData;

  const SyncConflictResolver({
    super.key, 
    required this.localData, 
    required this.cloudData
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24)
        ),
        title: const Text("Sync Conflict", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Data on this device is different from the server. Which version should we keep?",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _buildOption(context, "Local Version", localData['timestamp'], isLocal: true),
            const SizedBox(height: 12),
            _buildOption(context, "Cloud Version", cloudData['timestamp'], isLocal: false),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, String time, {required bool isLocal}) {
    return InkWell(
      onTap: () => Navigator.pop(context, isLocal),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocal ? Colors.blueAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Last updated: $time", style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
            const Icon(Icons.check_circle_outline, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
