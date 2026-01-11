import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/leagues/presentation/leagues_list_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/leagues/presentation/league_detail_screen.dart';
import '../../features/leagues/presentation/match_detail_screen.dart';
import '../../features/leagues/presentation/league_create_wizard.dart';
import '../../features/leagues/presentation/add_teams_screen.dart';
import '../../features/leagues/models/league_format.dart';

/// Auth state provider (simple example)
final authStateProvider = StateProvider<bool>((ref) => false);

/// App router configuration
final appRouter = GoRouter(
  initialLocation: '/', 
  routes: [
    /// Login Route
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// HomeShell with nested routes
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeShell(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'leagues',
          builder: (context, state) => const LeaguesListScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const LeagueCreateWizard(),
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
              path: 'detail',
              builder: (context, state) => const LeagueDetailScreen(leagueId: 'mock-id'),
            ),
            GoRoute(
              path: 'match',
              builder: (context, state) => const MatchDetailScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
