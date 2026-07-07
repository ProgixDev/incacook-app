import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/services/map/google_directions_client.dart';
import 'package:incacook/core/services/map/models/map_route.dart';

/// Fake Dio adapter: captures the outgoing request and returns a canned
/// Directions response so we can assert exactly what the client asked Google
/// for (origin / destination / waypoints) without a network call.
class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter(this.body);

  final String body;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// Classic Google-documented encoded polyline → 3 points:
// (38.5,-120.2), (40.7,-120.95), (43.252,-126.453).
const _encodedPolyline = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
const _okBody = '{"status":"OK","routes":[{"overview_polyline":{"points":'
    '"$_encodedPolyline"},"legs":[{"distance":{"value":1500},'
    '"duration":{"value":720}}]}]}';

void main() {
  const driver = MapPoint(lat: 48.8500, lng: 2.3500);
  const seller = MapPoint(lat: 48.8600, lng: 2.3400);
  const client = MapPoint(lat: 48.8700, lng: 2.3300);

  test(
    'pre-pickup itinerary: driver→seller→client sends the seller as a waypoint '
    'and origin/destination are driver/client',
    () async {
      final adapter = _CapturingAdapter(_okBody);
      final dio = Dio()..httpClientAdapter = adapter;
      final directions = GoogleDirectionsClient(dio: dio, apiKey: 'TEST_KEY');

      final route = await directions.getRouteThrough([driver, seller, client]);

      final q = adapter.captured!.queryParameters;
      expect(q['origin'], '48.85,2.35'); // driver
      expect(q['destination'], '48.87,2.33'); // client (itinerary ends here)
      expect(q['waypoints'], '48.86,2.34'); // seller in the middle
      expect(q['mode'], 'driving');
      expect(q['key'], 'TEST_KEY');

      // Polyline decoded into a real line, distance/duration parsed.
      expect(route.points.length, 3);
      expect(route.distanceMeters, 1500);
      expect(route.durationSeconds, 720);
    },
  );

  test(
    'post-pickup itinerary: driver→client sends no waypoints param',
    () async {
      final adapter = _CapturingAdapter(_okBody);
      final dio = Dio()..httpClientAdapter = adapter;
      final directions = GoogleDirectionsClient(dio: dio, apiKey: 'TEST_KEY');

      await directions.getRouteThrough([driver, client]);

      final q = adapter.captured!.queryParameters;
      expect(q['origin'], '48.85,2.35');
      expect(q['destination'], '48.87,2.33');
      expect(q.containsKey('waypoints'), isFalse);
    },
  );

  test('non-OK Directions status throws NoRouteFoundException', () async {
    final adapter = _CapturingAdapter('{"status":"ZERO_RESULTS","routes":[]}');
    final dio = Dio()..httpClientAdapter = adapter;
    final directions = GoogleDirectionsClient(dio: dio, apiKey: 'TEST_KEY');

    expect(
      () => directions.getRouteThrough([driver, client]),
      throwsA(isA<NoRouteFoundException>()),
    );
  });
}
