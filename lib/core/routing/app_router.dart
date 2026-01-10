import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import the specific screens
import '../../features/profile/presentation/profile_screen.dart';
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
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'leagues',
          builder: (context, state) => const LeaguesListScreen(),
        ),
      ],
    ),
  ],
);
