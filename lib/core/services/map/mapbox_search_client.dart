import 'package:dio/dio.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/services/map/models/place_suggestion.dart';

class MapboxSearchClient {
  MapboxSearchClient({Dio? dio, String? accessToken})
    : _dio = dio ?? Dio(),
      _accessToken =
          accessToken ?? const String.fromEnvironment('MAPBOX_PUBLIC_TOKEN');

  static const _baseUrl = 'https://api.mapbox.com/search/searchbox/v1';

  final Dio _dio;
  final String _accessToken;

  //* Generate a fresh session token at the start of each "search session".
  //* Mapbox bills per session (up to 50 /suggest + 1 /retrieve, idle timeout
  //* 2 min). Reuse the same token for every call within a session.
  String newSessionToken() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<List<PlaceSuggestion>> suggest({
    required String query,
    required String sessionToken,
    String? language,
    String? country,
    MapPoint? proximity,
    int limit = 8,
  }) async {
    if (query.trim().isEmpty) return [];

    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/suggest',
      queryParameters: {
        'q': query,
        'session_token': sessionToken,
        'access_token': _accessToken,
        'limit': limit,
        'language': ?language,
        'country': ?country,
        if (proximity != null) 'proximity': '${proximity.lng},${proximity.lat}',
      },
    );

    final suggestions =
        (response.data!['suggestions'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        const [];
    return suggestions
        .map(
          (s) => PlaceSuggestion(
            mapboxId: s['mapbox_id'] as String,
            name: s['name'] as String? ?? '',
            placeFormatted: s['place_formatted'] as String? ?? '',
            fullAddress: s['full_address'] as String?,
            featureType: s['feature_type'] as String? ?? '',
          ),
        )
        .toList();
  }

  Future<RetrievedPlace> retrieve({
    required String mapboxId,
    required String sessionToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/retrieve/$mapboxId',
      queryParameters: {
        'session_token': sessionToken,
        'access_token': _accessToken,
      },
    );

    final features = (response.data!['features'] as List)
        .cast<Map<String, dynamic>>();
    if (features.isEmpty) throw const PlaceNotFoundException();

    final feature = features.first;
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coords = (geometry['coordinates'] as List).cast<num>();

    return RetrievedPlace(
      mapboxId: mapboxId,
      name: properties['name'] as String? ?? '',
      placeFormatted: properties['place_formatted'] as String? ?? '',
      fullAddress: properties['full_address'] as String?,
      coordinate: MapPoint(
        lng: coords[0].toDouble(),
        lat: coords[1].toDouble(),
      ),
    );
  }
}

class PlaceNotFoundException implements Exception {
  const PlaceNotFoundException();

  @override
  String toString() =>
      'PlaceNotFoundException: Mapbox returned no place for the given mapbox_id.';
}
