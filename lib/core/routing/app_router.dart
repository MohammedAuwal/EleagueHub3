import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_shell.dart';
import '../../features/leagues/presentation/league_detail_screen.dart';
import '../../features/leagues/presentation/leagues_list_screen.dart';
import '../../features/leagues/presentation/match_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeShell(),
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
