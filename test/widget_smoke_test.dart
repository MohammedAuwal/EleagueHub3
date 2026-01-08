import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/routing/app_router.dart';

void main() {
  testWidgets('App shows home and can navigate to leagues', (tester) async {
    // 1. Load the router directly in a ProviderScope
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );

    // 2. Wait for GoRouter to settle at initialLocation '/'
    await tester.pumpAndSettle(); 

    // 3. Verify Home Shell / Dashboard is visible
    // 'Welcome back' is the text in your _HomeTab
    expect(find.text('Welcome back'), findsOneWidget);
    
    // 4. Verify the Navigation Bar is present
    expect(find.byType(NavigationBar), findsOneWidget);

    // 5. Test Tab Switching (Navigate to Leagues)
    final leaguesTab = find.text('Leagues');
    await tester.tap(leaguesTab);
    await tester.pumpAndSettle();

    // Verify index change (Assuming LeaguesListScreen has distinct text)
    expect(find.byIcon(Icons.emoji_events), findsWidgets);
  });
}
