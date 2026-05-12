import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_zones_request.freezed.dart';
part 'driver_zones_request.g.dart';

/// Body of `PUT /v1/drivers/me/zones` (§3.18). Free-text zone
/// identifiers in v1; v2 will promote to a `Zone` lookup table.
@freezed
abstract class DriverZonesRequest with _$DriverZonesRequest {
  const factory DriverZonesRequest({required List<String> zones}) =
      _DriverZonesRequest;

  factory DriverZonesRequest.fromJson(Map<String, dynamic> json) =>
      _$DriverZonesRequestFromJson(json);
}
