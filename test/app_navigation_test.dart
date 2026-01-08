import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';

void main() {
  testWidgets('App starts at login and can navigate to leagues', (tester) async {
    // 1. Load the app
    await tester.pumpWidget(const ProviderScope(child: EleagueHubApp()));

    // 2. Wait for the Login screen to settle
    await tester.pumpAndSettle();

    // 3. Verify we are at Login and tap 'Continue'
    expect(find.text('Mock auth for MVP. Tap continue to enter the app.'), findsOneWidget);
    await tester.tap(find.text('Continue'));

    // 4. Settle the transition to Home
    await tester.pumpAndSettle();

    // 5. Verify we are on Home (HomeShell)
    expect(find.text('EleagueHub'), findsWidgets);

    // 6. Navigate to Leagues tab
    final leaguesButton = find.text('Leagues');
    expect(leaguesButton, findsWidgets);
    await tester.tap(leaguesButton.first);

    // 7. Settle the navigation to the Leagues screen
    await tester.pumpAndSettle();

    // 8. Verify we are on the Leagues screen
    expect(find.byIcon(Icons.emoji_events), findsWidgets);
  });
}
