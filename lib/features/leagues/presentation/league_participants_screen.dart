import 'package:flutter/material.dart';
import 'dart:ui';
import 'qr_scanner_screen.dart';
import '../../logic/participants_service.dart';

class LeagueParticipantsScreen extends StatefulWidget {
  final String leagueId;
  const LeagueParticipantsScreen({super.key, required this.leagueId});

  @override
  State<LeagueParticipantsScreen> createState() => _LeagueParticipantsScreenState();
}

class _LeagueParticipantsScreenState extends State<LeagueParticipantsScreen> {
  final TextEditingController _controller = TextEditingController();
  late ParticipantsService _service;
  List<String> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = ParticipantsService();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() => _isLoading = true);
    final fetched = await _service.getParticipants(widget.leagueId);
    setState(() {
      _participants = fetched;
      _isLoading = false;
    });
  }

  Future<void> _addParticipant(String id) async {
    if (id.isEmpty) return;

    final success = await _service.addParticipant(widget.leagueId, id);
    if (success) {
      setState(() => _participants.add(id));
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$id added successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add $id. Already exists or invalid.")),
      );
    }
  }

  Future<void> _removeParticipant(String id) async {
    final success = await _service.removeParticipant(widget.leagueId, id);
    if (success) {
      setState(() => _participants.remove(id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$id removed.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to remove participant.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      appBar: AppBar(title: const Text("Participants"), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final scannedId = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScannerScreen()),
                );
                if (scannedId != null && scannedId is String) {
                  await _addParticipant(scannedId);
                }
              },
              icon: const Icon(Icons.qr_code),
              label: const Text("Add via QR Code"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            ),
            const SizedBox(height: 16),
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
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _participants.length,
                      itemBuilder: (context, index) {
                        final participant = _participants[index];
                        return Card(
                          color: Colors.white.withOpacity(0.1),
                          child: ListTile(
                            title: Text(participant, style: const TextStyle(color: Colors.white)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _removeParticipant(participant),
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
}
