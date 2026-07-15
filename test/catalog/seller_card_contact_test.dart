import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/features/catalog/presentation/widgets/seller_card.dart';

/// The seller identity block. It renders on the buyer product detail and — as
/// of the "profile image missing on my own dish" fix — on the seller's own
/// detail too, where the contact action must not appear: a seller can't message
/// themselves, and a disabled-but-visible chat button reads as broken.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );

  testWidgets('shows the chat action for a buyer viewing a seller', (
    tester,
  ) async {
    await pump(
      tester,
      const SellerCard(name: 'Chez Fethi', sellerUserId: 'seller-1'),
    );

    expect(find.byIcon(Iconsax.message), findsOneWidget);
  });

  testWidgets('hides the chat action on the seller\'s own dish', (tester) async {
    await pump(
      tester,
      const SellerCard(name: 'Chez Fethi', showContact: false),
    );

    expect(find.byIcon(Iconsax.message), findsNothing);
    // The identity itself still renders — that's the whole point of the block.
    expect(find.text('Chez Fethi'), findsOneWidget);
  });

  testWidgets('falls back to initials when the seller has no photo', (
    tester,
  ) async {
    await pump(
      tester,
      const SellerCard(name: 'Chez Fethi', initials: 'CF', showContact: false),
    );

    expect(find.text('CF'), findsOneWidget);
  });
}
