/// A driver-position update for an active delivery, as received over the
/// tracking WebSocket. Mirrors the backend payload emitted by
/// `TrackingGateway` on the `driver:location` event.
class DriverLocation {
  const DriverLocation({
    required this.deliveryId,
    required this.lat,
    required this.lng,
    required this.at,
    this.headingDeg,
    this.speedMps,
  });

  final String deliveryId;
  final double lat;
  final double lng;
  final DateTime at;
  final double? headingDeg;
  final double? speedMps;

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      deliveryId: json['deliveryId'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      at: DateTime.parse(json['at'] as String),
      headingDeg: (json['headingDeg'] as num?)?.toDouble(),
      speedMps: (json['speedMps'] as num?)?.toDouble(),
    );
  }
}
