import 'package:flutter/material.dart';
import '../widgets/my_fixtures_filter.dart';
import '../models/match.dart';
import '../models/team_stats.dart';
import '../logic/standings_engine.dart';

class LeagueDashboardScreen extends StatefulWidget {
  final String leagueId;

  const LeagueDashboardScreen({
    super.key,
    required this.leagueId,
  });

  @override
  State<LeagueDashboardScreen> createState() => _LeagueDashboardScreenState();
}

class _LeagueDashboardScreenState extends State<LeagueDashboardScreen> {
  bool filterByMe = false;

  /// These will later come from Provider / Backend
  final List<Match> _matches = [];
  final List<TeamStats> _teams = [];

  @override
  Widget build(BuildContext context) {
    final standings = StandingsEngine.compute(_teams, _matches);

    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      appBar: AppBar(
        title: const Text('League Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;

            return Column(
              children: [
                MyFixturesFilter(
                  onToggle: (val) => setState(() => filterByMe = val),
                ),
                Expanded(
                  child: isTablet
                      ? _buildTabletView(standings)
                      : _buildMobileView(standings),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ---------------- MOBILE ----------------

  Widget _buildMobileView(List<TeamStats> standings) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _sectionTitle("STANDINGS"),
        const SizedBox(height: 10),
        _buildStandingsList(standings),
        const SizedBox(height: 30),
        _sectionTitle("UPCOMING FIXTURES"),
        const SizedBox(height: 10),
        _buildFixturesList(),
      ],
    );
  }

  /// ---------------- TABLET ----------------

  Widget _buildTabletView(List<TeamStats> standings) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("STANDINGS"),
                const SizedBox(height: 10),
                _buildStandingsList(standings),
              ],
            ),
          ),
        ),
        VerticalDivider(color: Colors.white.withOpacity(0.15), width: 1),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("FIXTURES"),
                const SizedBox(height: 10),
                _buildFixturesList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ---------------- COMPONENTS ----------------

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildStandingsList(List<TeamStats> standings) {
    if (standings.isEmpty) {
      return _emptyBox("No standings yet");
    }

    return Column(
      children: standings.map((team) {
        return ListTile(
          leading: Text(
            team.position.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          title: Text(
            team.teamName,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: Text(
            "${team.points} pts",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFixturesList() {
    final fixtures = filterByMe
        ? _matches.where((m) => m.isMyMatch).toList()
        : _matches;

    if (fixtures.isEmpty) {
      return _emptyBox("No fixtures available");
    }

    return Column(
      children: fixtures.map((match) {
        return ListTile(
          title: Text(
            "${match.homeTeamName} vs ${match.awayTeamName}",
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            match.isPlayed ? "Finished" : "Upcoming",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: match.isPlayed
              ? Text(
                  "${match.homeScore} - ${match.awayScore}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Icon(Icons.chevron_right, color: Colors.white54),
        );
      }).toList(),
    );
  }

  Widget _emptyBox(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
