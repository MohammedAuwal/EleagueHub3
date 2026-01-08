import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';

void main() {
  testWidgets('App starts at login and can navigate to leagues via home', (tester) async {
    // 1. Build the app with ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: EleagueHubApp(),
      ),
    );

    // 2. Wait for initial route (/login) to load
    await tester.pumpAndSettle();

    // 3. Verify we are on Login Screen and tap "Continue"
    expect(find.text('EleagueHub'), findsWidgets);
    final continueButton = find.text('Continue');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);

    // 4. Settle transition to HomeShell
    await tester.pumpAndSettle();

    // 5. Verify Home Shell is visible
    expect(find.text('Welcome back'), findsOneWidget);

    // 6. Tap Leagues tab in the NavigationBar
    final leaguesTab = find.text('Leagues');
    expect(leaguesTab, findsWidgets);
    await tester.tap(leaguesTab.first);

    // 7. Settle navigation to Leagues Screen
    await tester.pumpAndSettle();

    // 8. Verify the Leagues screen content (Trophy Icon or Title)
    expect(find.byIcon(Icons.emoji_events), findsWidgets);
  });
}
