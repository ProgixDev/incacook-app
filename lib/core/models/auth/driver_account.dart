import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/features/authentication/data/models/driver_vehicle_type.dart';

part 'driver_account.freezed.dart';
part 'driver_account.g.dart';

/// The wizard-owned slice of a driver's account. Nested inside [User]
/// when `role == DRIVER`.
///
/// Mirrors `PUT /v1/drivers/me/vehicle` (§3.17) and
/// `PUT /v1/drivers/me/zones` (§3.18). Fields are nullable / empty until
/// the wizard fires those endpoints.
@freezed
abstract class DriverAccount with _$DriverAccount {
  const factory DriverAccount({
    DriverVehicleType? vehicleType,
    String? dateOfBirth,
    @Default(<String>[]) List<String> zones,
    @Default(false) bool canDeliver,
  }) = _DriverAccount;

  factory DriverAccount.fromJson(Map<String, dynamic> json) =>
      _$DriverAccountFromJson(json);
}
