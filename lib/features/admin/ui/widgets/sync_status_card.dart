import 'package:flutter/material.dart';
import '../../../core/services/sync_service.dart';

class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: const Icon(Icons.cloud_sync, color: Colors.cyanAccent),
        title: const Text("Cloud Synchronization", style: TextStyle(color: Colors.white)),
        subtitle: const Text("Keep local data and cloud in sync", style: TextStyle(color: Colors.white70)),
        trailing: IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () async {
            await SyncService().syncLocalToCloud();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Syncing complete!")),
            );
          },
        ),
      ),
    );
  }
}
