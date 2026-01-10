import 'package:flutter/material.dart';

import 'ui/screens/create_league_screen.dart';
import 'ui/screens/join_league_screen.dart';
import 'ui/screens/league_dashboard_screen.dart';

class LeaguesFeature {
  static const createLeagueRoute = '/leagues/create';
  static const joinLeagueRoute = '/leagues/join';
  static const dashboardRoute = '/leagues/dashboard';

  static Map<String, WidgetBuilder> get routes => {
        createLeagueRoute: (_) => const CreateLeagueScreen(),
        joinLeagueRoute: (_) => const JoinLeagueScreen(),
      };

  /// Use this when pushing to dashboard with a leagueId.
  static Route<dynamic> dashboardRouteFor(String leagueId) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: dashboardRoute),
      builder: (_) => LeagueDashboardScreen(leagueId: leagueId),
    );
  }
}
