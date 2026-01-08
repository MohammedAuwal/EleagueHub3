import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';

void main() {
  testWidgets('App boots and shows EleagueHub after login', (tester) async {
    // 1. Load the app
    await tester.pumpWidget(const ProviderScope(child: EleagueHubApp()));
    
    // 2. Wait for the Login screen to load
    await tester.pumpAndSettle();

    // 3. Tap 'Continue' to move past the mock auth screen
    await tester.tap(find.text('Continue'));
    
    // 4. Wait for the transition to the HomeShell
    await tester.pumpAndSettle();

    // 5. Now verify the app title is visible in the HomeShell
    expect(find.text('EleagueHub'), findsWidgets);
  });
}
