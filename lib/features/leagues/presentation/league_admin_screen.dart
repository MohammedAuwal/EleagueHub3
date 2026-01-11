import 'package:flutter/material.dart';
import 'dart:ui';

// Import the participants screen (assumes the file exists in the same directory)
import 'league_participants_screen.dart';

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
            _buildSettingsList(context),
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

  Widget _buildSettingsList(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          _buildSettingsTile(
            context,
            Icons.people,
            "Manage Participants",
            "Add or remove teams / view joined participants",
            onTap: () {
              // Navigate to participant management screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeagueParticipantsScreen(leagueId: "L-1"), // replace with actual leagueId
                ),
              );
            },
          ),
          _buildSettingsTile(context, Icons.rule, "League Rules", "Tiebreakers and deadlines"),
          _buildSettingsTile(context, Icons.notifications_active, "Notifications", "Alerts for scores"),
          _buildSettingsTile(context, Icons.delete_forever, "Delete League", "Permanent action", isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildGlassBox(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white30),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  Widget _buildGlassBox({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
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
