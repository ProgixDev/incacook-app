import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/features/moderation/presentation/report_sheet.dart';

/// #54 — ReportSheet must adapt its title + reason set to a message/user
/// target, not just the original listing shape.
void main() {
  Future<void> pump(WidgetTester tester, Widget sheet) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: sheet)));
  }

  testWidgets('message target shows the message title + message reasons', (tester) async {
    await pump(
      tester,
      const ReportSheet(target: ReportTarget.message, messageId: 'm1'),
    );

    expect(find.text('Signaler ce message'), findsOneWidget);
    expect(find.text('Spam'), findsOneWidget);
    expect(find.text('Contenu inapproprié'), findsOneWidget);
    // Listing-only reason must not leak into the message reason set.
    expect(find.text('Non fait maison'), findsNothing);
  });

  testWidgets('user target shows the user title + user reasons', (tester) async {
    await pump(
      tester,
      const ReportSheet(target: ReportTarget.user, userId: 'u1'),
    );

    expect(find.text('Signaler cet utilisateur'), findsOneWidget);
    expect(find.text('Faux profil'), findsOneWidget);
    expect(find.text('Non fait maison'), findsNothing);
  });

  testWidgets('listing target (default) keeps the original dish reasons', (tester) async {
    await pump(
      tester,
      const ReportSheet(listingId: 'l1', isFaitMaison: true),
    );

    expect(find.text('Signaler ce plat'), findsOneWidget);
    expect(find.text('Non fait maison'), findsOneWidget);
    expect(find.text('Mauvaise hygiène'), findsOneWidget);
  });
}
