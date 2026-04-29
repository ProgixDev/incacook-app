import 'dart:math' as math;

import 'package:homemade/core/services/map/models/map_route.dart';

/// Great-circle distance (Haversine) between two points, in meters.
double greatCircleDistance(MapPoint a, MapPoint b) {
  const earthRadius = 6371000.0;
  final lat1 = a.lat * math.pi / 180;
  final lat2 = b.lat * math.pi / 180;
  final dLat = (b.lat - a.lat) * math.pi / 180;
  final dLng = (b.lng - a.lng) * math.pi / 180;
  final h =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return 2 * earthRadius * math.asin(math.sqrt(h));
}

/// Distance from [p] to the segment [a]-[b], in meters. Uses lng/lat as a
/// flat plane to project the point — good enough for the urban-scale
/// segments produced by the Directions API.
double pointToSegmentDistance(MapPoint p, MapPoint a, MapPoint b) {
  final dx = b.lng - a.lng;
  final dy = b.lat - a.lat;
  final lenSq = dx * dx + dy * dy;
  if (lenSq == 0) return greatCircleDistance(p, a);
  var t = ((p.lng - a.lng) * dx + (p.lat - a.lat) * dy) / lenSq;
  t = t.clamp(0.0, 1.0);
  final closest = MapPoint(lng: a.lng + t * dx, lat: a.lat + t * dy);
  return greatCircleDistance(p, closest);
}

/// Minimum distance from [p] to any segment in [route], in meters.
double distanceToPolyline(MapPoint p, List<MapPoint> route) {
  if (route.isEmpty) return double.infinity;
  if (route.length == 1) return greatCircleDistance(p, route.first);
  var minDist = double.infinity;
  for (var i = 0; i < route.length - 1; i++) {
    final d = pointToSegmentDistance(p, route[i], route[i + 1]);
    if (d < minDist) minDist = d;
  }
  return minDist;
}
