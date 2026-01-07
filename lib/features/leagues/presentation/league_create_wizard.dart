import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/leagues_repository_mock.dart';

class LeagueCreateWizard extends StatefulWidget {
  const LeagueCreateWizard({super.key});

  @override
  State<LeagueCreateWizard> createState() => _LeagueCreateWizardState();
}

class _LeagueCreateWizardState extends State<LeagueCreateWizard> {
  final _repo = LeaguesRepositoryMock();

  int _step = 0;

  final _name = TextEditingController();
  String _format = 'Round Robin';
  String _privacy = 'Public';
  String _region = 'EU';
  int _maxTeams = 16;

  final _tbHeadToHead = true;
  bool _tbGoalDiff = true;
  bool _tbGoalsFor = false;

  int _proofDeadlineHours = 24;
  bool _forfeitEnabled = true;

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Glass(
            child: Stepper(
              currentStep: _step,
              controlsBuilder: (context, details) {
                final isLast = _step == 2;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      FilledButton(
                        onPressed: _submitting
                            ? null
                            : () async {
                                if (isLast) {
                                  await _create(context);
                                } else {
                                  setState(() => _step += 1);
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
                                  setState(() => _step -= 1);
                                }
                              },
                        child: Text(_step == 0 ? 'Cancel' : 'Back'),
                      ),
                      if (_submitting) ...[
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Basics'),
                  isActive: _step >= 0,
                  content: _basicsStep(context),
                ),
                Step(
                  title: const Text('Rules'),
                  isActive: _step >= 1,
                  content: _rulesStep(context),
                ),
                Step(
                  title: const Text('Review & Create'),
                  isActive: _step >= 2,
                  content: _reviewStep(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _basicsStep(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'League name',
            hintText: 'e.g. Friday Night Cup',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _format,
          items: const [
            DropdownMenuItem(value: 'Round Robin', child: Text('Round Robin')),
            DropdownMenuItem(
                value: 'UCL Groups+Knockout', child: Text('UCL Groups+Knockout')),
            DropdownMenuItem(value: 'Swiss', child: Text('Swiss')),
          ],
          onChanged: (v) => setState(() => _format = v ?? _format),
          decoration: const InputDecoration(labelText: 'Format'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _privacy,
          items: const [
            DropdownMenuItem(value: 'Public', child: Text('Public')),
            DropdownMenuItem(value: 'Private', child: Text('Private')),
          ],
          onChanged: (v) => setState(() => _privacy = v ?? _privacy),
          decoration: const InputDecoration(labelText: 'Privacy'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _region,
          items: const [
            DropdownMenuItem(value: 'EU', child: Text('EU')),
            DropdownMenuItem(value: 'NA', child: Text('NA')),
            DropdownMenuItem(value: 'APAC', child: Text('APAC')),
            DropdownMenuItem(value: 'LATAM', child: Text('LATAM')),
          ],
          onChanged: (v) => setState(() => _region = v ?? _region),
          decoration: const InputDecoration(labelText: 'Region'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: Text('Max teams')),
            DropdownButton<int>(
              value: _maxTeams,
              items: const [8, 12, 16, 24, 32]
                  .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                  .toList(),
              onChanged: (v) => setState(() => _maxTeams = v ?? _maxTeams),
            ),
          ],
        ),
      ],
    );
  }

  Widget _rulesStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tiebreakers', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _check('Head-to-head', value: _tbHeadToHead, onChanged: null),
        _check(
          'Goal difference',
          value: _tbGoalDiff,
          onChanged: (v) => setState(() => _tbGoalDiff = v ?? _tbGoalDiff),
        ),
        _check(
          'Goals for',
          value: _tbGoalsFor,
          onChanged: (v) => setState(() => _tbGoalsFor = v ?? _tbGoalsFor),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: Text('Proof deadline (hours)')),
            DropdownButton<int>(
              value: _proofDeadlineHours,
              items: const [6, 12, 24, 48, 72]
                  .map((h) => DropdownMenuItem(value: h, child: Text('$h')))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _proofDeadlineHours = v ?? _proofDeadlineHours),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Forfeit enabled'),
          subtitle: const Text('Allow automatic forfeits when deadline passes.'),
          value: _forfeitEnabled,
          onChanged: (v) => setState(() => _forfeitEnabled = v),
        ),
      ],
    );
  }

  Widget _reviewStep(BuildContext context) {
    final tiebreakers = _tiebreakers();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kv('Name', _name.text.isEmpty ? '(unnamed)' : _name.text),
        _kv('Format', _format),
        _kv('Privacy', _privacy),
        _kv('Region', _region),
        _kv('Max teams', '$_maxTeams'),
        _kv('Tiebreakers', tiebreakers.join(', ')),
        _kv('Proof deadline', '$_proofDeadlineHours hours'),
        _kv('Forfeit', _forfeitEnabled ? 'Enabled' : 'Disabled'),
        const SizedBox(height: 8),
        Text(
          'Note: This is mock creation. No backend is connected yet.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  Widget _check(String label,
      {required bool value, required ValueChanged<bool?>? onChanged}) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(label),
    );
  }

  List<String> _tiebreakers() {
    final out = <String>['Head-to-head'];
    if (_tbGoalDiff) out.add('Goal difference');
    if (_tbGoalsFor) out.add('Goals for');
    return out;
  }

  Future<void> _create(BuildContext context) async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a league name.')),
      );
      setState(() => _step = 0);
      return;
    }

    setState(() => _submitting = true);
    try {
      await _repo.createLeague(
        name: name,
        format: _format,
        privacy: _privacy,
        region: _region,
        maxTeams: _maxTeams,
        forfeitEnabled: _forfeitEnabled,
        proofDeadlineHours: _proofDeadlineHours,
        tiebreakers: _tiebreakers(),
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('League created (mock).')),
      );
      context.pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
