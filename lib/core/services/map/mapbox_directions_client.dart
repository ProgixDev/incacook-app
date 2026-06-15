import 'package:dio/dio.dart';
import 'package:incacook/core/config/mapbox_config.dart';
import 'package:incacook/core/services/map/models/map_route.dart';

class MapboxDirectionsClient {
  MapboxDirectionsClient({Dio? dio, String? accessToken})
    : _dio = dio ?? Dio(),
      _accessToken = accessToken ?? MapboxConfig.publicToken,
      assert(
        (accessToken ?? MapboxConfig.publicToken).isNotEmpty,
        MapboxConfig.missingTokenMessage,
      );

  static const _baseUrl = 'https://api.mapbox.com/directions/v5/mapbox';

  final Dio _dio;
  final String _accessToken;

  //* Profile values per the Directions API: 'driving-traffic', 'driving',
  //* 'walking', 'cycling'. Default to driving-traffic for delivery.
  Future<MapRoute> getRoute({
    required MapPoint origin,
    required MapPoint destination,
    String profile = 'driving-traffic',
  }) => getRouteThrough([origin, destination], profile: profile);

  /// Routes through an ordered list of [waypoints] (≥ 2 points). The Directions
  /// API accepts up to 25 coordinates, so e.g. `[driver, seller, client]`
  /// returns ONE connected geometry covering both legs — letting the buyer's
  /// tracking map draw the whole path between the driver, the seller (pickup)
  /// and the client (dropoff) as a single line.
  Future<MapRoute> getRouteThrough(
    List<MapPoint> waypoints, {
    String profile = 'driving-traffic',
  }) async {
    if (waypoints.length < 2) {
      throw ArgumentError('getRouteThrough requires at least 2 waypoints');
    }
    final coords = waypoints.map((p) => '${p.lng},${p.lat}').join(';');

    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/$profile/$coords',
      queryParameters: {
        'geometries': 'geojson',
        'overview': 'full',
        'access_token': _accessToken,
      },
    );

    final routes = (response.data!['routes'] as List).cast<Map<String, dynamic>>();
    if (routes.isEmpty) throw const NoRouteFoundException();

    final route = routes.first;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = (geometry['coordinates'] as List).cast<List>();

    return MapRoute(
      points: coordinates
          .map(
            (c) => MapPoint(lng: (c[0] as num).toDouble(), lat: (c[1] as num).toDouble()),
          )
          .toList(),
      distanceMeters: (route['distance'] as num).toDouble(),
      durationSeconds: (route['duration'] as num).toDouble(),
    );
  }
}

class NoRouteFoundException implements Exception {
  const NoRouteFoundException();

  @override
  String toString() => 'NoRouteFoundException: Mapbox returned no routes.';
}
