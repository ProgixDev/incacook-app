import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/features/seller/presentation/widgets/seller_product_card.dart';

/// Regression for the "Mes plats" list bug where a dish with a long name
/// pushed the availability switch off the right edge, so the toggle silently
/// disappeared on that row. The name must now flex/ellipsize and the switch
/// must always render and stay tappable — even on a narrow screen.
FoodListing _listing({required String name}) => FoodListing(
  id: 'l1',
  name: name,
  // http URL routes through Image.network, which Flutter's test harness
  // stubs with a transparent image (an asset path would throw in tests).
  imageUrl: 'https://example.com/food.png',
  sellerName: 'Chef',
  category: SellerCategory.faitMaison,
  price: 4.5,
  portionsLeft: 3,
  fulfillment: Fulfillment.pickup,
  expiresAt: DateTime(2030),
  menuCategory: 'Plat du jour',
  prepMinutes: 10,
);

Widget _host(Widget child) => MediaQuery(
  // Narrow logical width, mimicking an iPhone-7-class screen.
  data: const MediaQueryData(size: Size(320, 640)),
  child: MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 300, child: child)),
    ),
  ),
);

void main() {
  testWidgets('renders the availability switch even with a very long name', (
    tester,
  ) async {
    bool? toggled;
    await tester.pumpWidget(
      _host(
        SellerProductCard(
          product: _listing(
            name: 'Câble à la confiture de mamie façon grand-mère du village',
          ),
          onAvailabilityChanged: (v) => toggled = v,
        ),
      ),
    );
    await tester.pump();

    // The switch is present and, crucially, hit-testable (not off-screen).
    expect(find.byType(Switch), findsOneWidget);
    await tester.tap(find.byType(Switch));
    expect(toggled, isNotNull);
  });

  testWidgets('renders the availability switch with a short name too', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SellerProductCard(
          product: _listing(name: 'Pizza'),
          onAvailabilityChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Switch), findsOneWidget);
  });
}
