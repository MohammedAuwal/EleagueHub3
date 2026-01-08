import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';

void main() {
  testWidgets('App boots and shows EleagueHub after login', (tester) async {
    // 1. Build the app
    await tester.pumpWidget(const ProviderScope(child: EleagueHubApp()));
    
    // 2. Wait for Login Screen to appear
    await tester.pumpAndSettle();

    // 3. Find the Continue button by its text and tap it
    final continueButton = find.text('Continue');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    
    // 4. Wait for the GoRouter and AnimatedSwitcher transitions
    await tester.pumpAndSettle();

    // 5. Verify we are on the Home screen by looking for the NavigationBar
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
