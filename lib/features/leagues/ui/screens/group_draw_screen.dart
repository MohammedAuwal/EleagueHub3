import 'package:flutter/material.dart';
import '../widgets/glass_group_card.dart';
import 'dart:async';

class GroupDrawScreen extends StatefulWidget {
  final List<String> allTeams;
  const GroupDrawScreen({super.key, required this.allTeams});

  @override
  State<GroupDrawScreen> createState() => _GroupDrawScreenState();
}

class _GroupDrawScreenState extends State<GroupDrawScreen> {
  Map<String, List<String>> groups = {
    "Group A": [], "Group B": [], "Group C": [], "Group D": [],
    "Group E": [], "Group F": [], "Group G": [], "Group H": [],
  };
  
  List<String> remainingTeams = [];
  bool isDrawing = false;

  @override
  void initState() {
    super.initState();
    remainingTeams = List.from(widget.allTeams)..shuffle();
  }

  void startDraw() async {
    setState(() => isDrawing = true);
    
    int groupIndex = 0;
    List<String> groupNames = groups.keys.toList();

    while (remainingTeams.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 600)); // The "Stagger" effect
      
      setState(() {
        String team = remainingTeams.removeAt(0);
        groups[groupNames[groupIndex % 8]]!.add(team);
        groupIndex++;
      });
    }

    setState(() => isDrawing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      appBar: AppBar(title: const Text("UCL Group Draw"), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          if (remainingTeams.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: isDrawing ? null : startDraw,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                child: Text(isDrawing ? "Drawing Teams..." : "START AUTOMATIC DRAW"),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.9,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                String key = groups.keys.elementAt(index);
                return GlassGroupCard(title: key, teams: groups[key]!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
