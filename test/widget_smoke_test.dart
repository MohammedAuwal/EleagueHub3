import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';

void main() {
  testWidgets('App shows login and can navigate to home', (tester) async {
    // 1. Load the full app within ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: EleagueHubApp(),
      ),
    );

    // 2. Wait for the Login screen to load
    await tester.pumpAndSettle(); 

    // 3. Verify we are on the Login Screen
    expect(find.text('EleagueHub'), findsWidgets);
    expect(find.text('Continue'), findsOneWidget);

    // 4. Trigger Login
    await tester.tap(find.text('Continue'));
    
    // 5. Use multiple pumps to avoid animation timeouts
    // This is safer than pumpAndSettle if your UI has infinite glass animations
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 6. Verify we reached the Home Shell
    // 'Welcome back' is the header in your _HomeTab
    expect(find.text('Welcome back'), findsOneWidget);
    
    // 7. Test navigation to Leagues Tab
    await tester.tap(find.text('Leagues'));
    await tester.pumpAndSettle();

    // Verify the Leagues icon/content is visible
    expect(find.byIcon(Icons.emoji_events), findsWidgets);
  });
}
