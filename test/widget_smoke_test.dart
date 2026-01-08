import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/main.dart'; // Pointing to your actual entry point

void main() {
  testWidgets('App shows login and can navigate to home', (tester) async {
    // Start the app with Riverpod ProviderScope
    await tester.pumpWidget(const ProviderScope(child: EleagueHubApp()));

    // 1. Verify Login Screen (Updated to match your actual UI text)
    expect(find.text('EleagueHub'), findsOneWidget);
    
    // Assuming your Login button says "Login" or "Continue"
    final loginButton = find.byType(ElevatedButton).first;
    await tester.tap(loginButton);
    
    // Wait for the navigation animation (AnimatedSwitcher in HomeShell)
    await tester.pumpAndSettle();

    // 2. Verify Home Shell / Dashboard
    // We look for "Welcome back" from your _HomeTab implementation
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Leagues'), findsWidgets);
  });
}
