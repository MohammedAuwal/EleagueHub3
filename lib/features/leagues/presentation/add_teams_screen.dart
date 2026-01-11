import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/league_format.dart';

class AddTeamsScreen extends StatefulWidget {
  final String leagueId;
  final LeagueFormat format; // Classic, UCL Group, or UCL Swiss

  const AddTeamsScreen({
    super.key, 
    required this.leagueId, 
    required this.format
  });

  @override
  State<AddTeamsScreen> createState() => _AddTeamsScreenState();
}

class _AddTeamsScreenState extends State<AddTeamsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _singleController = TextEditingController();
  final _bulkController = TextEditingController();
  
  List<Map<String, String>> _tempTeams = [];
  String _selectedGroup = "Group A";
  final List<String> _groups = ["Group A", "Group B", "Group C", "Group D", "Group E", "Group F", "Group G", "Group H"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _addTeam(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (_tempTeams.any((t) => t['name'] == trimmed)) return; // prevent duplicates

    setState(() {
      _tempTeams.add({
        'name': trimmed,
        'group': widget.format == LeagueFormat.uclGroup ? _selectedGroup : "League Pool",
      });

      // Auto-advance group for UCL Groups
      if (widget.format == LeagueFormat.uclGroup) {
        final nextIndex = (_groups.indexOf(_selectedGroup) + 1) % _groups.length;
        _selectedGroup = _groups[nextIndex];
      }
    });
  }

  void _importBulk() {
    if (_bulkController.text.isNotEmpty) {
      final names = _bulkController.text.split(RegExp(r'[,\n]'));
      for (var n in names) {
        _addTeam(n);
      }
      _bulkController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000428),
      appBar: AppBar(
        title: Text('Add Teams: ${widget.format.displayName}'),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [Tab(text: 'Single Entry'), Tab(text: 'Bulk Import')],
        ),
      ),
      body: Column(
        children: [
          if (widget.format == LeagueFormat.uclGroup) _buildGroupSelector(),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSingleEntry(),
                _buildBulkEntry(),
              ],
            ),
          ),
          _buildTeamListPreview(),
        ],
      ),
    );
  }

  Widget _buildGroupSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text("Assign to:", style: TextStyle(color: Colors.white70)),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButton<String>(
                value: _selectedGroup,
                dropdownColor: const Color(0xFF000428),
                underline: const SizedBox(),
                isExpanded: true,
                style: const TextStyle(color: Colors.cyanAccent),
                items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => _selectedGroup = val!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleEntry() {
    return _buildGlassBox(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _singleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter Team Name...',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none
              ),
              onSubmitted: (val) {
                 _addTeam(val);
                 _singleController.clear();
              },
            ),
          ),
          IconButton(
            onPressed: () {
              _addTeam(_singleController.text);
              _singleController.clear();
            }, 
            icon: const Icon(Icons.add_circle, color: Colors.cyanAccent, size: 30)
          ),
        ],
      ),
    );
  }

  Widget _buildBulkEntry() {
    return _buildGlassBox(
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _bulkController,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Paste teams here (comma or newline separated)',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: _importBulk, 
            child: const Text('ADD ALL TO LIST')
          ),
        ],
      ),
    );
  }

  Widget _buildTeamListPreview() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("PREVIEW TEAM LIST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tempTeams.length,
              itemBuilder: (context, i) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  child: Text("${i + 1}", style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                ),
                title: Text(_tempTeams[i]['name']!, style: const TextStyle(color: Colors.white)),
                subtitle: Text(_tempTeams[i]['group']!, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => setState(() => _tempTeams.removeAt(i)),
                ),
              ),
            ),
          ),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent.withOpacity(0.2),
              minimumSize: const Size(double.infinity, 55),
              side: const BorderSide(color: Colors.cyanAccent),
            ),
            onPressed: () {
              if (_tempTeams.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add at least one team to continue')),
                );
                return;
              }
              // TODO: Implement SAVE & START LEAGUE LOGIC
            },
            child: const Text('GENERATE LEAGUE FIXTURES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBox({required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }
}
