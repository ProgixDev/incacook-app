import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/core/models/cart_item.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/core/models/fulfillment_options.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/cart/controllers/cart_controller.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';

FoodListing _listing() => FoodListing(
  id: 'l1',
  name: 'Tarte',
  imageUrl: 'https://example.com/food.png',
  sellerName: 'Chef',
  category: SellerCategory.faitMaison,
  price: 4.5,
  portionsLeft: 3,
  fulfillment: Fulfillment.pickup,
  expiresAt: DateTime(2030),
);

CartItem _item(String id) => CartItem(
  id: id,
  listing: _listing(),
  quantity: 1,
  selectedAddOns: const [],
  note: '',
);

/// Captures the `idempotencyKey` passed to `post()` without touching the
/// network — `OrdersRepository.createOrder` should forward a stable,
/// caller-supplied key rather than letting `post()` mint a fresh random one
/// per call (that's the mechanism the server's create-order dedup relies on).
class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(dio: Dio(), tokenStorage: TokenStorage());

  final List<String?> capturedKeys = [];

  @override
  Future<ApiSuccess<T>> post<T>(
    String path, {
    required T Function(Object? json) decoder,
    Object? body,
    String? idempotencyKey,
    bool requiresIdempotencyKey = false,
  }) async {
    capturedKeys.add(idempotencyKey);
    return ApiSuccess<T>(
      decoder({
        'order': {'id': 'order-1', 'orderNumber': '001', 'status': 'PENDING'},
        'paymentIntentClientSecret': 'secret',
      }),
    );
  }
}

void main() {
  group('CartController.checkoutIdempotencyKey', () {
    test('is stable across repeated reads for an unchanged cart', () {
      final cart = CartController();
      final key1 = cart.checkoutIdempotencyKey;
      final key2 = cart.checkoutIdempotencyKey;
      expect(key1, key2);
    });

    test('changes after the cart is mutated', () async {
      final cart = CartController();
      final firstKey = cart.checkoutIdempotencyKey;

      await cart.tryAdd(
        _item(''),
        resolveConflict: (_) async => true,
      );

      expect(cart.checkoutIdempotencyKey, isNot(firstKey));
    });

    test('changes after clear()', () {
      final cart = CartController();
      final firstKey = cart.checkoutIdempotencyKey;
      cart.clear();
      expect(cart.checkoutIdempotencyKey, isNot(firstKey));
    });
  });

  group('OrdersRepository.createOrder idempotency forwarding', () {
    test('forwards an explicit idempotencyKey to the API client', () async {
      final api = _RecordingApiClient();
      final repo = OrdersRepository(api: api);

      await repo.createOrder(
        items: [_item('l1-1')],
        fulfillmentChoice: FulfillmentChoice.pickup,
        idempotencyKey: 'attempt-key-1',
      );

      expect(api.capturedKeys, ['attempt-key-1']);
    });

    test('two calls with the same explicit key send the same key twice', () async {
      final api = _RecordingApiClient();
      final repo = OrdersRepository(api: api);

      for (var i = 0; i < 2; i++) {
        await repo.createOrder(
          items: [_item('l1-1')],
          fulfillmentChoice: FulfillmentChoice.pickup,
          idempotencyKey: 'attempt-key-1',
        );
      }

      expect(api.capturedKeys, ['attempt-key-1', 'attempt-key-1']);
    });
  });
}
