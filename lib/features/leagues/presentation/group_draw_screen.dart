import 'package:flutter/material.dart';
import '../widgets/glass_group_card.dart';
import '../../domain/models.dart';
import '../../data/leagues_repository_mock.dart';

class GroupDrawScreen extends StatefulWidget {
  final String leagueId;
  const GroupDrawScreen({super.key, required this.leagueId});

  @override
  State<GroupDrawScreen> createState() => _GroupDrawScreenState();
}

class _GroupDrawScreenState extends State<GroupDrawScreen> {
  static final Map<String, Map<String, List<TeamStats>>> _savedDraws = {};
  late Map<String, List<TeamStats>> groups;
  late List<TeamStats> remainingTeams;
  bool isDrawing = false;

  @override
  void initState() {
    super.initState();

    // Fetch teams dynamically from repository (simulate AddTeamsScreen)
    final allLeagueTeams = LeaguesRepositoryMock().getTeamsForLeague(widget.leagueId);

    // Load saved draw if exists
    if (_savedDraws.containsKey(widget.leagueId)) {
      groups = Map<String, List<TeamStats>>.from(_savedDraws[widget.leagueId]!);
      // Collect remaining teams
      remainingTeams = allLeagueTeams.where((t) {
        return !groups.values.any((grp) => grp.contains(t));
      }).toList();
    } else {
      // Initialize empty groups
      groups = {
        "Group A": [], "Group B": [], "Group C": [], "Group D": [],
        "Group E": [], "Group F": [], "Group G": [], "Group H": [],
      };
      remainingTeams = List.from(allLeagueTeams)..shuffle();
    }

    // Optionally, start draw automatically if any remaining teams
    if (remainingTeams.isNotEmpty) {
      startDraw();
    }
  }

  void startDraw() async {
    if (remainingTeams.isEmpty) return;

    setState(() => isDrawing = true);

    int groupIndex = groups.values.fold<int>(
      0,
      (prev, grp) => prev + grp.length,
    );
    List<String> groupNames = groups.keys.toList();

    while (remainingTeams.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        final team = remainingTeams.removeAt(0);
        groups[groupNames[groupIndex % 8]]!.add(team);
        groupIndex++;
      });
    }

    // Save partial/final draw
    _savedDraws[widget.leagueId] = Map<String, List<TeamStats>>.from(groups);

    setState(() => isDrawing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      appBar: AppBar(
        title: const Text("UCL Group Draw"),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          if (remainingTeams.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: isDrawing ? null : startDraw,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                child: Text(isDrawing ? "Drawing Teams..." : "RESUME DRAW"),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.9,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                String key = groups.keys.elementAt(index);
                final teamNames = groups[key]!.map((t) => t.teamName).toList();
                return GlassGroupCard(title: key, teams: teamNames);
              },
            ),
          ),
        ],
      ),
    );
  }
}
