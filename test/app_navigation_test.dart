import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';

void main() {
  testWidgets('App starts at login and can navigate to leagues', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EleagueHubApp()));
    
    // Allow the router to load the /login route
    await tester.pumpAndSettle();

    // Verify Login Screen (Matches the actual text in login_screen.dart)
    expect(find.textContaining('Tap continue'), findsOneWidget);
    
    // Tap Continue to log in
    await tester.tap(find.text('Continue'));
    
    // Wait for navigation transition (HomeShell)
    await tester.pumpAndSettle();

    // Verify we are now on the Home Screen
    expect(find.text('Welcome back'), findsOneWidget);

    // Navigate to Leagues
    await tester.tap(find.text('Leagues'));
    await tester.pumpAndSettle();

    // Verify Leagues icon is visible
    expect(find.byIcon(Icons.emoji_events), findsWidgets);
  });
}
