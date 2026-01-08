import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/main.dart'; 

void main() {
  testWidgets('App shows login and can navigate to home', (tester) async {
    // 1. Load the app
    // Note: Ensure EleagueHubApp is the name of your widget in main.dart
    await tester.pumpWidget(
      const ProviderScope(
        child: EleagueHubApp(),
      ),
    );

    // 2. Verify we are on the Login Screen
    // GoRouter initialLocation is /login
    await tester.pumpAndSettle(); 
    expect(find.text('EleagueHub'), findsOneWidget);
    
    // 3. Trigger Login
    // Since authStateProvider starts as false, tapping a button 
    // that triggers login logic is required. 
    // In this smoke test, we simulate the navigation.
    final loginButton = find.byType(ElevatedButton);
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    
    // 4. Wait for GoRouter and AnimatedSwitcher
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // 5. Verify Home Shell / Dashboard
    // 'Welcome back' is the header in your _HomeTab
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
