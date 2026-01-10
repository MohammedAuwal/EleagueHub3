import 'package:flutter/material.dart';
import '../widgets/my_fixtures_filter.dart';
import 'league_leaderboard_screen.dart'; // Reuse our glass table

class LeagueDashboardScreen extends StatefulWidget {
  const LeagueDashboardScreen({super.key});

  @override
  State<LeagueDashboardScreen> createState() => _LeagueDashboardScreenState();
}

class _LeagueDashboardScreenState extends State<LeagueDashboardScreen> {
  bool filterByMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth > 600;
            
            return Column(
              children: [
                MyFixturesFilter(onToggle: (val) => setState(() => filterByMe = val)),
                Expanded(
                  child: isTablet ? _buildTabletView() : _buildMobileView(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("STANDINGS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        // ... build small table
        const SizedBox(height: 30),
        const Text("UPCOMING FIXTURES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        // ... build match list (filtered by filterByMe)
      ],
    );
  }

  Widget _buildTabletView() {
    return Row(
      children: [
        const Expanded(flex: 2, child: SingleChildScrollView(child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Glass Standing Table Here"),
        ))),
        VerticalDivider(color: Colors.white.withOpacity(0.1), width: 1),
        const Expanded(flex: 3, child: SingleChildScrollView(child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Glass Fixtures List Here"),
        ))),
      ],
    );
  }
}
