import 'package:eleaguehub/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App shows login and can navigate to home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EleagueHubApp()));

    expect(find.text('EleagueHub'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
  });
}
