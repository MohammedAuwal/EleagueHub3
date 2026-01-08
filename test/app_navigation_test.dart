import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';

void main() {
  testWidgets('App boots and shows EleagueHub after login', (tester) async {
    // 1. Build the app
    await tester.pumpWidget(const ProviderScope(child: EleagueHubApp()));
    
    // 2. Allow router to initialize
    await tester.pump();
    // Use a specific duration to bypass animation delays
    await tester.pump(const Duration(seconds: 1));

    // 3. Find button by type instead of text (more reliable)
    final loginButton = find.byType(FilledButton);
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    
    // 4. Settle the transition to Home
    await tester.pumpAndSettle();

    // 5. Verify the Home Shell NavigationBar exists
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
