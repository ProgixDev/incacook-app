import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/supply_catalog/data/supply_catalog_repository.dart';

/// Captures every `post()` call's path + idempotencyKey without touching the
/// network. `SupplyCatalogRepository.createOrder` should (a) require an
/// idempotency key at all — the pre-fix code sent none — and (b) forward a
/// caller-supplied key rather than always minting a fresh one.
class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(dio: Dio(), tokenStorage: TokenStorage());

  final List<({String path, String? idempotencyKey, bool requiresKey})>
  calls = [];

  @override
  Future<ApiSuccess<T>> post<T>(
    String path, {
    required T Function(Object? json) decoder,
    Object? body,
    String? idempotencyKey,
    bool requiresIdempotencyKey = false,
  }) async {
    calls.add(
      (
        path: path,
        idempotencyKey: idempotencyKey,
        requiresKey: requiresIdempotencyKey,
      ),
    );
    return ApiSuccess<T>(
      decoder({
        'orderId': 'catalog-order-1',
        'clientSecret': 'secret',
        'totalCents': 500,
        'currency': 'eur',
      }),
    );
  }
}

void main() {
  group('SupplyCatalogRepository.createOrder idempotency', () {
    test('requires an idempotency key on the create-order POST', () async {
      final api = _RecordingApiClient();
      final repo = SupplyCatalogRepository(api: api);

      await repo.createOrder(productId: 'p1', quantity: 1);

      expect(api.calls.single.requiresKey, isTrue);
    });

    test('forwards a caller-supplied idempotency key', () async {
      final api = _RecordingApiClient();
      final repo = SupplyCatalogRepository(api: api);

      await repo.createOrder(
        productId: 'p1',
        quantity: 1,
        idempotencyKey: 'attempt-key-1',
      );

      expect(api.calls.single.idempotencyKey, 'attempt-key-1');
    });

    test('two calls with the same explicit key send the same key twice', () async {
      final api = _RecordingApiClient();
      final repo = SupplyCatalogRepository(api: api);

      for (var i = 0; i < 2; i++) {
        await repo.createOrder(
          productId: 'p1',
          quantity: 1,
          idempotencyKey: 'attempt-key-1',
        );
      }

      expect(api.calls.map((c) => c.idempotencyKey), [
        'attempt-key-1',
        'attempt-key-1',
      ]);
    });
  });
}
