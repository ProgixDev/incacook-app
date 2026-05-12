import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/features/authentication/data/models/driver_vehicle_type.dart';

part 'driver_vehicle_request.freezed.dart';
part 'driver_vehicle_request.g.dart';

/// Body of `PUT /v1/drivers/me/vehicle` (§3.17). The wizard collects
/// vehicle type and DOB on the same screen, so both fields land in one
/// call — [dateOfBirth] is optional only because PATCHing vehicle later
/// shouldn't require resending DOB.
@freezed
abstract class DriverVehicleRequest with _$DriverVehicleRequest {
  const factory DriverVehicleRequest({
    required DriverVehicleType vehicleType,
    String? dateOfBirth, // YYYY-MM-DD
  }) = _DriverVehicleRequest;

  factory DriverVehicleRequest.fromJson(Map<String, dynamic> json) =>
      _$DriverVehicleRequestFromJson(json);
}
