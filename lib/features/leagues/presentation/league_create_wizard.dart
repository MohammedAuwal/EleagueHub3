import "../models/league_format.dart";
import '../models/league.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

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
      appBar: AppBar(title: const Text('Create League')),
      // Use Center to align the content in the middle
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            // Limits width on large devices while staying responsive on phones
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
                          onPressed: _submitting
                              ? null
                              : () async {
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
                          onPressed: _submitting
                              ? null
                              : () {
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
          decoration: const InputDecoration(labelText: 'League name'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<LeagueFormat>(
          value: _format,
          items: const [
            DropdownMenuItem(value: LeagueFormat.classic, child: Text('Round Robin')),
            DropdownMenuItem(value: LeagueFormat.uclGroup, child: Text('UCL Groups + Knockout')),
            DropdownMenuItem(value: LeagueFormat.uclSwiss, child: Text('Swiss')),
          ],
          onChanged: (v) => setState(() => _format = v!),
          decoration: const InputDecoration(labelText: 'Format'),
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
          title: const Text('Goal difference'),
        ),
        CheckboxListTile(
          value: _tbGoalsFor,
          onChanged: (v) => setState(() => _tbGoalsFor = v!),
          title: const Text('Goals for'),
        ),
      ],
    );
  }

  Widget _reviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name: ${_name.text}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Format: ${_format.name}'),
        Text('Max Teams: $_maxTeams'),
      ],
    );
  }

  Future<void> _create(BuildContext context) async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    final leagueId = _uuid.v4();

    if (!context.mounted) return;

    // Standardized path for nested routes
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
