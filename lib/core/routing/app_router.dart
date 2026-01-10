import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_shell.dart';
import '../../features/leagues/presentation/league_detail_screen.dart';
import '../../features/leagues/presentation/leagues_list_screen.dart';
import '../../features/leagues/presentation/match_detail_screen.dart';
import '../../features/auth/presentation/login_screen.dart';

// Declare global provider for the login state
final authStateProvider = StateProvider<bool>((ref) => false);

final appRouter = GoRouter(
  initialLocation: '/', // Set to /login for the MVP start
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'leagues',
          builder: (context, state) => const LeaguesListScreen(),
        ),
        GoRoute(
          path: 'leagues/:leagueId',
          builder: (context, state) {
            final id = state.pathParameters['leagueId'] ?? 'unknown';
            return LeagueDetailScreen(leagueId: id);
          },
        ),
        GoRoute(
          path: 'leagues/:leagueId/matches/:matchId',
          builder: (context, state) {
            final leagueId = state.pathParameters['leagueId'] ?? 'unknown';
            final matchId = state.pathParameters['matchId'] ?? 'unknown';
            return MatchDetailScreen(
              leagueId: leagueId,
              matchId: matchId,
            );
          },
        ),
      ],
    ),
  ],
);
