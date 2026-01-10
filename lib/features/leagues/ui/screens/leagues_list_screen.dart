import 'package:flutter/material.dart';
import '../widgets/glass_search_bar.dart';
import '../widgets/league_flip_card.dart';

class LeaguesListScreen extends StatelessWidget {
  final List<dynamic> leagues; 

  const LeaguesListScreen({super.key, required this.leagues});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7), // Your light blue theme
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const GlassSearchBar(),
            const SizedBox(height: 10),
            Expanded(
              child: leagues.isEmpty 
                ? _buildEmptyState(context) 
                : _buildLeaguesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Leagues',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 100, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 20),
          const Text("No active leagues", style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSimpleButton("Create", Icons.add, context),
              const SizedBox(width: 20),
              _buildSimpleButton("Join", Icons.qr_code, context),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSimpleButton(String label, IconData icon, BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.white30),
      ),
    );
  }

  Widget _buildLeaguesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: leagues.length,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: LeagueFlipCard(
            leagueName: "UCL Season 1",
            leagueCode: "CHAMP99",
            distribution: "Swiss Model • 32 Teams",
          ),
        );
      },
    );
  }
}
