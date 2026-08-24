import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/common/widgets/login_signup/social_buttons.dart';

/// #53 — the Apple button must default to hidden on a non-iOS host (this
/// test suite always runs on macOS/Linux CI, so `Platform.isIOS` is false)
/// and must render when explicitly requested.
void main() {
  testWidgets('Apple button is hidden by default on a non-iOS platform', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SocialButtons(onApple: () {}))),
    );
    expect(find.byIcon(Icons.apple), findsNothing);
  });

  testWidgets('Apple button renders when showApple is forced true', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SocialButtons(onApple: () {}, showApple: true)),
      ),
    );
    expect(find.byIcon(Icons.apple), findsOneWidget);
  });

  testWidgets('Apple button does not render when showApple is forced false', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SocialButtons(onApple: () {}, showApple: false)),
      ),
    );
    expect(find.byIcon(Icons.apple), findsNothing);
  });
}
