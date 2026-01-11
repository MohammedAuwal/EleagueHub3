import 'package:flutter/material.dart';
import 'dart:ui';
import '../../logic/participants_service.dart';
import 'league_participants_screen.dart';

class LeagueAdminScreen extends StatefulWidget {
  final bool hasPendingChanges;
  final String leagueId;

  const LeagueAdminScreen({super.key, this.hasPendingChanges = true, required this.leagueId});

  @override
  State<LeagueAdminScreen> createState() => _LeagueAdminScreenState();
}

class _LeagueAdminScreenState extends State<LeagueAdminScreen> {
  final ParticipantsService _participantsService = ParticipantsService();
  bool _isSyncing = false;

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
            widget.hasPendingChanges ? Icons.cloud_off : Icons.cloud_done,
            color: widget.hasPendingChanges ? Colors.orangeAccent : Colors.greenAccent,
            size: 40,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hasPendingChanges ? "Offline Changes" : "Fully Synced",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.hasPendingChanges ? "Pending upload" : "Up to date with server",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (widget.hasPendingChanges)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
              onPressed: _isSyncing ? null : _syncParticipants,
              child: _isSyncing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text("SYNC", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Future<void> _syncParticipants() async {
    setState(() => _isSyncing = true);
    await _participantsService.syncParticipants(widget.leagueId);
    setState(() => _isSyncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Participants synced successfully!")),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeagueParticipantsScreen(leagueId: widget.leagueId),
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
