import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/leagues_repository_local.dart';
import '../models/membership.dart';
import '../models/team.dart';

class LeagueParticipantsScreen extends ConsumerStatefulWidget {
  final String leagueId;

  const LeagueParticipantsScreen({
    super.key,
    required this.leagueId,
  });

  @override
  ConsumerState<LeagueParticipantsScreen> createState() =>
      _LeagueParticipantsScreenState();
}

class _LeagueParticipantsScreenState
    extends ConsumerState<LeagueParticipantsScreen> {
  late LocalLeaguesRepository _repo;

  bool _loading = true;
  List<Membership> _memberships = [];
  Map<String, Team> _teamsById = {};

  @override
  void initState() {
    super.initState();
    _repo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
    _load();
  }

  Future<void> _load() async {
    final allMemberships = await _repo.listMemberships();
    final leagueMembers = allMemberships
        .where((m) => m.leagueId == widget.leagueId)
        .toList();

    final teams = await _repo.getTeams(widget.leagueId);

    if (!mounted) return;
    setState(() {
      _memberships = leagueMembers;
      _teamsById = {
        for (final t in teams) t.id: t,
      };
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Participants'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.cyanAccent,
                    ),
                  )
                : _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_memberships.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Glass(
          borderRadius: 24,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.people_outline,
                  size: 40,
                  color: Colors.cyanAccent,
                ),
                SizedBox(height: 12),
                Text(
                  'No participants yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Participants will appear here after they join via code/QR or are assigned to teams.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final organizers = _memberships
        .where((m) => m.role == LeagueRole.organizer)
        .toList();
    final members = _memberships
        .where((m) => m.role == LeagueRole.member)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        if (organizers.isNotEmpty) ...[
          const Text(
            'Organizers',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...organizers.map(_buildMembershipTile),
          const SizedBox(height: 16),
        ],
        const Text(
          'Participants',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        ...members.map(_buildMembershipTile),
      ],
    );
  }

  Widget _buildMembershipTile(Membership m) {
    final teamName = (m.teamId != null && m.teamId!.isNotEmpty)
        ? _teamsById[m.teamId!]?.name ?? 'Team ${m.teamId}'
        : 'No team';

    final isOrganizer = m.role == LeagueRole.organizer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Glass(
        borderRadius: 18,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isOrganizer
                ? Colors.cyanAccent.withOpacity(0.2)
                : Colors.white.withOpacity(0.08),
            child: Icon(
              isOrganizer ? Icons.verified_user : Icons.person,
              color:
                  isOrganizer ? Colors.cyanAccent : Colors.white70,
              size: 18,
            ),
          ),
          title: Text(
            m.userId,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            isOrganizer ? 'Organizer • $teamName' : teamName,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
