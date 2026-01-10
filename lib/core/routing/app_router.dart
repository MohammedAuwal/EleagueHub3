import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import the Screen causing the error
import '../../features/profile/presentation/profile_screen.dart';

// Existing Imports
import '../../features/home/presentation/home_shell.dart';
import '../../features/leagues/presentation/league_detail_screen.dart';
import '../../features/leagues/presentation/leagues_list_screen.dart';
import '../../features/leagues/presentation/match_detail_screen.dart';
import '../../features/auth/presentation/login_screen.dart';

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
      // Set ProfileScreen as the landing page to verify your recent Glass UI changes
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
            // Logic for Classic, UCL Classic, and UCL Swiss will branch inside here later
            return LeagueDetailScreen(leagueId: id);
          },
        ),
      ],
    ),
  ],
);
