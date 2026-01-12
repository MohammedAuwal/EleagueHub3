import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/leagues/models/league_format.dart';
import '../../features/leagues/presentation/add_teams_screen.dart';
import '../../features/leagues/presentation/league_create_wizard.dart';
import '../../features/leagues/presentation/league_detail_screen.dart';
import '../../features/leagues/presentation/leagues_list_screen.dart';
import '../../features/leagues/presentation/match_detail_screen.dart';
import '../../features/leagues/presentation/qr_scanner_screen.dart';
import '../../features/live/presentation/join_match_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

final authStateProvider = StateProvider<bool>((ref) => false);

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeShell(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        // Live Tab Routes
        GoRoute(
          path: 'live/join',
          builder: (context, state) => const JoinMatchScreen(),
        ),
        // League Tab Routes
        GoRoute(
          path: 'leagues',
          builder: (context, state) => const LeaguesListScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const LeagueCreateWizard(),
            ),
            GoRoute(
              path: 'join-scanner',
              builder: (context, state) => const QRScannerScreen(),
            ),
            GoRoute(
              path: 'add-teams',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                final leagueId = extra['leagueId'] as String? ?? 'mock-id';
                final format = extra['format'] as LeagueFormat? ?? LeagueFormat.classic;
                return AddTeamsScreen(
                  leagueId: leagueId,
                  format: format,
                );
              },
            ),
            GoRoute(
              path: ':leagueId',
              builder: (context, state) {
                final leagueId = state.pathParameters['leagueId']!;
                return LeagueDetailScreen(leagueId: leagueId);
              },
            ),
            GoRoute(
              path: ':leagueId/matches/:matchId',
              builder: (context, state) {
                final leagueId = state.pathParameters['leagueId']!;
                final matchId = state.pathParameters['matchId']!;
                return MatchDetailScreen(
                  leagueId: leagueId,
                  matchId: matchId,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
