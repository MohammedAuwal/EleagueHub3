import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import "../models/league_format.dart";
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';

class LeagueCreateWizard extends StatefulWidget {
  const LeagueCreateWizard({super.key});

  @override
  State<LeagueCreateWizard> createState() => _LeagueCreateWizardState();
}

class _LeagueCreateWizardState extends State<LeagueCreateWizard> {
  final _uuid = const Uuid();
  int _step = 0;

  final _name = TextEditingController();
  LeagueFormat _format = LeagueFormat.classic;
  final int _maxTeams = 16;

  bool _tbGoalDiff = true;
  bool _tbGoalsFor = false;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are on a wide screen
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Create League'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              // THIS FIXES THE STRETCHING
              constraints: BoxConstraints(maxWidth: isWide ? 600 : 450),
              child: Glass(
                child: Stepper(
                  physics: const NeverScrollableScrollPhysics(),
                  currentStep: _step,
                  controlsBuilder: (context, details) {
                    final isLast = _step == 2;
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _submitting ? null : () {
                              if (_step == 0) {
                                context.pop();
                              } else {
                                setState(() => _step--);
                              }
                            },
                            child: Text(_step == 0 ? 'Cancel' : 'Back'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _submitting ? null : () async {
                              if (isLast) {
                                await _create(context);
                              } else {
                                if (_step == 0 && _name.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a league name')),
                                  );
                                  return;
                                }
                                setState(() => _step++);
                              }
                            },
                            child: _submitting 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(isLast ? 'Create' : 'Next'),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(title: const Text('Basics'), content: _basicsStep(), isActive: _step >= 0),
                    Step(title: const Text('Rules'), content: _rulesStep(), isActive: _step >= 1),
                    Step(title: const Text('Review'), content: _reviewStep(), isActive: _step >= 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _basicsStep() {
    return Column(
      children: [
        TextField(
          controller: _name,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'League name',
            prefixIcon: Icon(Icons.edit_note, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<LeagueFormat>(
          value: _format,
          dropdownColor: const Color(0xFF0A1D37),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Tournament Format'),
          items: const [
            DropdownMenuItem(value: LeagueFormat.classic, child: Text('Round Robin')),
            DropdownMenuItem(value: LeagueFormat.uclGroup, child: Text('UCL Groups + Knockout')),
            DropdownMenuItem(value: LeagueFormat.uclSwiss, child: Text('UCL Swiss Model')),
          ],
          onChanged: (v) => setState(() => _format = v!),
        ),
      ],
    );
  }

  Widget _rulesStep() {
    return Column(
      children: [
        CheckboxListTile(
          value: _tbGoalDiff,
          activeColor: Colors.cyanAccent,
          onChanged: (v) => setState(() => _tbGoalDiff = v!),
          title: const Text('Goal Difference Tiebreaker', style: TextStyle(color: Colors.white)),
        ),
        CheckboxListTile(
          value: _tbGoalsFor,
          activeColor: Colors.cyanAccent,
          onChanged: (v) => setState(() => _tbGoalsFor = v!),
          title: const Text('Goals For Tiebreaker', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _reviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.label, 'Name', _name.text),
        _infoRow(Icons.format_list_bulleted, 'Format', _format.displayName),
        _infoRow(Icons.groups, 'Max Teams', '$_maxTeams'),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.cyanAccent),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    final leagueId = _uuid.v4();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!context.mounted) return;
    context.push('/leagues/add-teams', extra: {'leagueId': leagueId, 'format': _format});
    setState(() => _submitting = false);
  }
}
