import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';

void main() {
  testWidgets('App boots and shows EleagueHub after login', (tester) async {
    // 1. Build the app
    await tester.pumpWidget(const ProviderScope(child: EleagueHubApp()));
    
    // 2. Wait for the Login screen to actually exist
    bool foundButton = false;
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byType(FilledButton).evaluate().isNotEmpty) {
        foundButton = true;
        break;
      }
    }
    
    expect(foundButton, isTrue, reason: 'Login button did not appear in time');

    // 3. Tap the button
    await tester.tap(find.byType(FilledButton));
    
    // 4. Settle the transition to Home
    await tester.pumpAndSettle();

    // 5. Verify the Home Shell NavigationBar exists
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
