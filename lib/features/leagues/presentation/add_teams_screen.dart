import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/section_header.dart';
import '../data/leagues_repository_local.dart';
import '../models/league_format.dart';
import '../models/team.dart';
import '../models/fixture_match.dart';
import '../domain/algorithms/round_robin.dart';

class AddTeamsScreen extends ConsumerStatefulWidget {
  final String leagueId;
  final LeagueFormat format;

  const AddTeamsScreen({
    super.key,
    required this.leagueId,
    required this.format,
  });

  @override
  ConsumerState<AddTeamsScreen> createState() => _AddTeamsScreenState();
}

class _AddTeamsScreenState extends ConsumerState<AddTeamsScreen> {
  late LocalLeaguesRepository _localRepo;
  final _bulkController = TextEditingController();
  final List<Map<String, String>> _tempTeams = [];

  String _selectedGroup = 'Group A';
  final List<String> _groups = const [
    'Group A', 'Group B', 'Group C', 'Group D',
    'Group E', 'Group F', 'Group G', 'Group H',
  ];

  @override
  void initState() {
    super.initState();
    _localRepo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
  }

  void _addTeam(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (_tempTeams.any((t) => t['name'] == trimmed)) return;

    setState(() {
      _tempTeams.add({
        'name': trimmed,
        'group': widget.format == LeagueFormat.uclGroup
            ? _selectedGroup
            : 'League Pool',
      });

      if (widget.format == LeagueFormat.uclGroup) {
        final next = (_groups.indexOf(_selectedGroup) + 1) % _groups.length;
        _selectedGroup = _groups[next];
      }
    });
  }

  void _importBulk() {
    final text = _bulkController.text;
    if (text.isEmpty) return;

    for (final name in text.split(RegExp(r'[,\n]'))) {
      if (name.trim().isNotEmpty) _addTeam(name);
    }
    _bulkController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _generateAndSave() async {
    if (_tempTeams.isEmpty) return;

    final List<Team> teamsToSave = _tempTeams.map((t) {
      return Team(
        id: const Uuid().v4(),
        leagueId: widget.leagueId,
        name: t['name']!,
        updatedAtMs: DateTime.now().millisecondsSinceEpoch,
        version: 1,
      );
    }).toList();

    await _localRepo.saveTeams(widget.leagueId, teamsToSave);

    List<FixtureMatch> generatedFixtures = [];
    final teamIds = teamsToSave.map((t) => t.id).toList();

    if (widget.format == LeagueFormat.classic) {
      generatedFixtures = RoundRobinGenerator.generate(
        leagueId: widget.leagueId,
        teamIds: teamIds,
        doubleRoundRobin: true,
        startRoundNumber: 1,
      );
    } else if (widget.format == LeagueFormat.uclGroup) {
      for (var groupName in _groups) {
        final groupTeams = teamsToSave
            .where((t) => _tempTeams.firstWhere((temp) => temp['name'] == t.name)['group'] == groupName)
            .map((t) => t.id)
            .toList();
        
        if (groupTeams.isNotEmpty) {
          generatedFixtures.addAll(
            RoundRobinGenerator.generate(
              leagueId: widget.leagueId,
              teamIds: groupTeams,
              doubleRoundRobin: true,
              groupId: groupName,
              startRoundNumber: 1,
            ),
          );
        }
      }
    }

    if (generatedFixtures.isNotEmpty) {
      await _localRepo.saveMatches(widget.leagueId, generatedFixtures);
    }

    if (mounted) {
      context.go('/leagues/${widget.leagueId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return GlassScaffold(
      appBar: AppBar(
        title: Text('Add Teams · ${widget.format.displayName}'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          // Centering the layout and limiting width to stop it from stretching
          constraints: BoxConstraints(maxWidth: isWide ? 600 : 500),
          child: Column(
            children: [
              if (widget.format == LeagueFormat.uclGroup)
                _buildGroupSelector(),
              Expanded(child: _buildBulkEntry()),
              _buildPreviewPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Glass(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            const Text('Assign to', style: TextStyle(color: Colors.white70)),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGroup,
                  dropdownColor: const Color(0xFF000428),
                  style: const TextStyle(color: Colors.cyanAccent),
                  isExpanded: true,
                  items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => _selectedGroup = v!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkEntry() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Glass(
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _bulkController,
                maxLines: null,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Paste team names (comma or new line separated)',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton(
                onPressed: _importBulk,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
                child: const Text('ADD TEAMS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      height: 320,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        color: Colors.black.withOpacity(0.2),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SectionHeader('Team Preview'),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _tempTeams.length,
              itemBuilder: (context, i) {
                final team = _tempTeams[i];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                    child: Text('${i + 1}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 10)),
                  ),
                  title: Text(team['name']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text(team['group']!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white24, size: 18),
                    onPressed: () => setState(() => _tempTeams.removeAt(i)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FilledButton(
              onPressed: _tempTeams.isEmpty ? null : _generateAndSave,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('GENERATE FIXTURES', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
