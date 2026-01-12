import '../../domain/models.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/leagues_repository_mock.dart';
import '../domain/models.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({
    super.key,
    required this.leagueId,
    required this.matchId,
    this.repository,
  });

  final String leagueId;
  final String matchId;

  /// Allows future backend injection
  final LeaguesRepositoryMock? repository;

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  late final LeaguesRepositoryMock _repo;

  final _note = TextEditingController();
  final _reason = TextEditingController();

  bool _busy = false;

  /// TEMP: will come from Match model later
  String _status = 'Pending Proof';

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? LeaguesRepositoryMock();
  }

  @override
  void dispose() {
    _note.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(title: const Text('Match Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildProofUpload(context),
          const SizedBox(height: 12),
          _buildOrganizerReview(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Glass(
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.matchId, // TODO: replace with "PlayerA vs PlayerB"
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          StatusBadge(_status),
        ],
      ),
    );
  }

  Widget _buildProofUpload(BuildContext context) {
    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload proof',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              labelText: 'Note',
              hintText: 'Optional details for the organizer',
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy ? null : () => _uploadProof(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Proof'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MVP: This simulates proof upload and moves match to "Under Review".',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerReview(BuildContext context) {
    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Organizer review (mock)',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reason,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _review(false),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : () => _review(true),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Future<void> _uploadProof(BuildContext context) async {
    setState(() => _busy = true);
    try {
      await _repo.uploadProofPlaceholder(
        leagueId: widget.leagueId,
        matchId: widget.matchId,
        note: _note.text.trim(),
      );
      if (!mounted) return;

      setState(() => _status = 'Under Review');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proof uploaded (mock).')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _review(bool approve) async {
    setState(() => _busy = true);
    try {
      await _repo.organizerReviewDecision(
        leagueId: widget.leagueId,
        matchId: widget.matchId,
        decision: MatchReviewDecision.approve
          approved: approve,
          reason: _reason.text.trim(),
        ),
      );
      if (!mounted) return;

      setState(() {
        _status = approve ? 'Completed' : 'Pending Proof';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? 'Approved (mock).' : 'Rejected (mock).'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
