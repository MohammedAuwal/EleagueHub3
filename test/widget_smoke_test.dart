import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';
import 'package:eleaguehub/core/routing/app_router.dart';

void main() {
  testWidgets('App shows login and can navigate to home', (tester) async {
    // 1. Build the app with ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: EleagueHubApp(),
      ),
    );

    // 2. Initial pump to allow GoRouter to parse the initialLocation
    await tester.pump(); 

    // 3. Verify Login Screen (Check for EleagueHub text)
    expect(find.text('EleagueHub'), findsWidgets);
    
    // 4. Find and Tap "Continue"
    final continueButton = find.text('Continue');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    
    // 5. Manually pump frames to handle the 220ms AnimatedSwitcher in HomeShell
    // This avoids the 'pumpAndSettle timed out' error
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // 6. Verify Home Shell reached (Check for 'Welcome back')
    expect(find.text('Welcome back'), findsOneWidget);
    
    // 7. Test Tab Switching
    final leaguesTab = find.text('Leagues');
    await tester.tap(leaguesTab);
    
    // 8. Final settle for the tab transition
    await tester.pumpAndSettle();

    // Verify we are on the Leagues tab ( Trophy/Emoji icon)
    expect(find.byIcon(Icons.emoji_events), findsWidgets);
  });
}
