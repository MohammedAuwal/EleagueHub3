import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleaguehub/core/app/app.dart';

void main() {
  testWidgets('App can render a frame', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: EleagueHubApp()));
    
    // We use pump() to trigger the first frame build.
    await tester.pump();
    
    // Simplest assertion to confirm the test completes successfully.
    expect(true, isTrue);
  });
}
