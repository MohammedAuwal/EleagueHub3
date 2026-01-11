import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'dart:ui';

class LeagueParticipantsScreen extends StatefulWidget {
  final String leagueId;

  const LeagueParticipantsScreen({super.key, required this.leagueId});

  @override
  State<LeagueParticipantsScreen> createState() => _LeagueParticipantsScreenState();
}

class _LeagueParticipantsScreenState extends State<LeagueParticipantsScreen> {
  final List<String> _participants = []; // Replace with DB/API fetch
  final TextEditingController _controller = TextEditingController();

  // Add participant manually
  void _addParticipant(String id) {
    if (id.isEmpty) return;
    if (_participants.contains(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$id is already in the league!")),
      );
      return;
    }

    setState(() {
      _participants.add(id);
    });

    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$id added successfully!")),
    );
  }

  // Remove participant
  void _removeParticipant(String id) {
    setState(() {
      _participants.remove(id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$id removed.")),
    );
  }

  // Open QR scanner to add participant
  Future<void> _scanQRCode() async {
    final scannedId = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (scannedId != null && scannedId is String) {
      _addParticipant(scannedId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      appBar: AppBar(
        title: const Text("Participants"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add via QR Code
            ElevatedButton.icon(
              onPressed: _scanQRCode,
              icon: const Icon(Icons.qr_code),
              label: const Text("Add via QR Code"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            ),
            const SizedBox(height: 16),

            // Add manually
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white12,
                      hintText: "Enter Participant ID or Name",
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addParticipant(_controller.text.trim()),
                  child: const Text("Add"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // List of participants
            Expanded(
              child: _participants.isEmpty
                  ? _emptyBox("No participants yet")
                  : ListView.builder(
                      itemCount: _participants.length,
                      itemBuilder: (context, index) {
                        final participant = _participants[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildGlassBox(
                            child: ListTile(
                              title: Text(
                                participant,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _removeParticipant(participant),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyBox(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white70),
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
