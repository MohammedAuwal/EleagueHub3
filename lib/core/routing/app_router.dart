import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/leagues/presentation/league_create_wizard.dart';
import '../../features/leagues/presentation/league_detail_screen.dart';
import '../../features/leagues/presentation/match_detail_screen.dart';
import '../../features/live/presentation/join_match_screen.dart';
import '../../features/live/presentation/live_view_screen.dart';
import '../../features/marketplace/presentation/listing_detail_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';

final authStateProvider = StateProvider<bool>((ref) => false);

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthed = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final loggingIn = state.uri.path == '/login';
      
      if (!isAuthed) {
        return loggingIn ? null : '/login';
      }
      if (loggingIn) return '/';
      return null;
    },
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
            path: 'leagues/create',
            builder: (context, state) => const LeagueCreateWizard(),
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
            builder: (context, state) => MatchDetailScreen(
              leagueId: state.pathParameters['leagueId']!,
              matchId: state.pathParameters['matchId']!,
            ),
          ),
          GoRoute(
            path: 'live/join',
            builder: (context, state) => const JoinMatchScreen(),
          ),
          GoRoute(
            path: 'live/view/:matchId',
            builder: (context, state) =>
                LiveViewScreen(matchId: state.pathParameters['matchId']!),
          ),
          GoRoute(
            path: 'marketplace/listing/:listingId',
            builder: (context, state) => ListingDetailScreen(
              listingId: state.pathParameters['listingId']!,
            ),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen<bool>(authStateProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}
