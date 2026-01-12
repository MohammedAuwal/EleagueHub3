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
    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Create League'),
        // Dynamic color based on format selection
        backgroundColor: _format == LeagueFormat.classic ? Colors.green.withOpacity(0.5) : Colors.indigo.withOpacity(0.5),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Glass(
              child: Stepper(
                physics: const NeverScrollableScrollPhysics(),
                currentStep: _step,
                controlsBuilder: (context, details) {
                  final isLast = _step == 2;
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
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
                          child: Text(isLast ? 'Create' : 'Next'),
                        ),
                        const SizedBox(width: 12),
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
                        if (_submitting) ...[
                          const SizedBox(width: 12),
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
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
    );
  }

  Widget _basicsStep() {
    return Column(
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'League name',
            prefixIcon: Icon(Icons.edit_note),
          ),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<LeagueFormat>(
          value: _format,
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
          onChanged: (v) => setState(() => _tbGoalDiff = v!),
          title: const Text('Goal Difference Tiebreaker'),
          secondary: const Icon(Icons.compare_arrows),
        ),
        CheckboxListTile(
          value: _tbGoalsFor,
          onChanged: (v) => setState(() => _tbGoalsFor = v!),
          title: const Text('Goals For Tiebreaker'),
          secondary: const Icon(Icons.exposure_plus_1),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _submitting = true);

    final leagueId = _uuid.v4();
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (!context.mounted) return;

    // Use absolute nested path
    context.push(
      '/leagues/add-teams',
      extra: {
        'leagueId': leagueId,
        'format': _format,
      },
    );
    setState(() => _submitting = false);
  }
}
