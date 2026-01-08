import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';

void main() {
  testWidgets('App starts at login and can navigate to leagues', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EleagueHubApp()));
    
    // Wait for GoRouter to load the initial route
    await tester.pumpAndSettle();

    // Verify Login Screen by looking for the Title and the Button
    expect(find.text('EleagueHub'), findsWidgets);
    expect(find.text('Continue'), findsOneWidget);
    
    // Tap Continue
    await tester.tap(find.text('Continue'));
    
    // Settle transition to Home
    await tester.pumpAndSettle();

    // Verify Home reached (NavigationBar should be present)
    expect(find.byType(NavigationBar), findsOneWidget);

    // Navigate to Leagues
    await tester.tap(find.text('Leagues'));
    await tester.pumpAndSettle();

    // Verify Leagues screen (Search for the trophy icon)
    expect(find.byIcon(Icons.emoji_events), findsWidgets);
  });
}
