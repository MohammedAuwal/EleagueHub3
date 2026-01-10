import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/league_format.dart';

class LeagueLeaderboardScreen extends StatelessWidget {
  final LeagueFormat format;
  final String leagueName;

  const LeagueLeaderboardScreen({
    super.key, 
    required this.format, 
    required this.leagueName
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7), // Matching your Home theme
      appBar: AppBar(
        title: Text('$leagueName Standings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: format == LeagueFormat.uclGroup 
          ? _buildGroupView() 
          : _buildSingleTableView(),
      ),
    );
  }

  // View for UCL Groups (A, B, C...)
  Widget _buildGroupView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8, // Groups A through H
      itemBuilder: (context, index) {
        String groupLetter = String.fromCharCode(65 + index);
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text("GROUP $groupLetter", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              _buildGlassTable(teamCount: 4),
            ],
          ),
        );
      },
    );
  }

  // View for Classic or Swiss League
  Widget _buildSingleTableView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTableHead(),
          Expanded(child: _buildGlassTable(teamCount: 20)),
        ],
      ),
    );
  }

  Widget _buildTableHead() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          Expanded(flex: 1, child: Text("#", style: TextStyle(color: Colors.white60, fontSize: 12))),
          Expanded(flex: 4, child: Text("TEAM", style: TextStyle(color: Colors.white60, fontSize: 12))),
          Expanded(child: Text("P", style: TextStyle(color: Colors.white60, fontSize: 12))),
          Expanded(child: Text("GD", style: TextStyle(color: Colors.white60, fontSize: 12))),
          Expanded(child: Text("PTS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildGlassTable({required int teamCount}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: teamCount,
            separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
            itemBuilder: (context, index) {
              return _buildTeamRow(index + 1);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(int rank) {
    bool isQualified = rank <= 2; // For UCL/Swiss progression highlight
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 1, 
            child: Text("$rank", style: TextStyle(color: isQualified ? Colors.cyanAccent : Colors.white70))
          ),
          const Expanded(
            flex: 4, 
            child: Text("Team Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
          ),
          const Expanded(child: Text("0", style: TextStyle(color: Colors.white70))),
          const Expanded(child: Text("0", style: TextStyle(color: Colors.white70))),
          const Expanded(child: Text("0", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
