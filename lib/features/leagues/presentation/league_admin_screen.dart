import 'package:flutter/material.dart';
import 'dart:ui';

class LeagueAdminScreen extends StatelessWidget {
  final bool hasPendingChanges;

  const LeagueAdminScreen({super.key, this.hasPendingChanges = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      appBar: AppBar(title: const Text("League Settings"), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSyncCard(),
            const SizedBox(height: 20),
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncCard() {
    return _buildGlassBox(
      child: Row(
        children: [
          Icon(
            hasPendingChanges ? Icons.cloud_off : Icons.cloud_done,
            color: hasPendingChanges ? Colors.orangeAccent : Colors.greenAccent,
            size: 40,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPendingChanges ? "Offline Changes" : "Fully Synced",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  hasPendingChanges ? "3 matches pending upload" : "Up to date with server",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (hasPendingChanges)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
              onPressed: () {}, // Trigger Sync Logic
              child: const Text("SYNC", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return _buildGlassBox(
      child: Column(
        children: [
          _buildSettingItem(Icons.edit, "Edit League Name"),
          const Divider(color: Colors.white10),
          _buildSettingItem(Icons.timer, "Change Match Duration"),
          const Divider(color: Colors.white10),
          _buildSettingItem(Icons.person_remove, "Remove a Team", isDestructive: true),
          const Divider(color: Colors.white10),
          _buildSettingItem(Icons.refresh, "Reset League Standings", isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
    );
  }

  Widget _buildGlassBox({required Widget child}) {
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
          child: child,
        ),
      ),
    );
  }
}
