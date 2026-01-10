import 'package:flutter/material.dart';
import 'dart:ui';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7), // Consistent light blue theme
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildSettingsGroup("App Preferences", [
              _SettingItem(Icons.notifications_none, "Notifications", "Alerts & Sounds"),
              _SettingItem(Icons.dark_mode_outlined, "Appearance", "Glassmorphism Mode"),
              _SettingItem(Icons.language, "Language", "English"),
            ]),
            const SizedBox(height: 24),
            _buildSettingsGroup("Account & Security", [
              _SettingItem(Icons.lock_outline, "Privacy", "Manage your data"),
              _SettingItem(Icons.sync, "Cloud Sync", "Last synced: 2m ago"),
              _SettingItem(Icons.delete_forever, "Delete Account", "Irreversible action", isDestructive: true),
            ]),
            const SizedBox(height: 40),
            const Text("eSportlyic v1.0.0-PRO", style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return _buildGlassBox(
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.cyanAccent, width: 2),
              image: const DecorationImage(image: NetworkImage('https://via.placeholder.com/150')),
            ),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("League Manager", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text("pro_organizer@email.com", style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 20)),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<_SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
        _buildGlassBox(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.map((item) {
              final isLast = items.indexOf(item) == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: item.isDestructive ? Colors.redAccent : Colors.white70),
                    title: Text(item.title, style: TextStyle(color: item.isDestructive ? Colors.redAccent : Colors.white, fontWeight: FontWeight.w500)),
                    subtitle: Text(item.subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
                    onTap: () {},
                  ),
                  if (!isLast) Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 50),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassBox({required Widget child, EdgeInsets padding = const EdgeInsets.all(20)}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  _SettingItem(this.icon, this.title, this.subtitle, {this.isDestructive = false});
}
