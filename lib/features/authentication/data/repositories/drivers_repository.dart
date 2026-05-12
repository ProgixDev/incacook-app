import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/auth/driver_account.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/features/authentication/data/models/requests/driver_vehicle_request.dart';
import 'package:incacook/features/authentication/data/models/requests/driver_zones_request.dart';

/// Repository for driver-only endpoints under `/v1/drivers/me/*`.
class DriversRepository extends GetxService {
  DriversRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static DriversRepository get instance => Get.find();

  final ApiClient _api;

  /// `PUT /v1/drivers/me/vehicle` (§3.17). Sets vehicle type and DOB
  /// (collected on the same wizard screen). Returns the updated
  /// [DriverAccount] slice.
  Future<DriverAccount> setVehicle(DriverVehicleRequest req) async {
    final result = await _api.put<DriverAccount>(
      '${ApiConstants.apiPrefix}/drivers/me/vehicle',
      body: req.toJson(),
      decoder: (json) => DriverAccount.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `PUT /v1/drivers/me/zones` (§3.18). Replaces the operating-zones
  /// list in one call.
  Future<void> setZones(DriverZonesRequest req) async {
    await _api.put<void>(
      '${ApiConstants.apiPrefix}/drivers/me/zones',
      body: req.toJson(),
      decoder: (_) {},
    );
  }
}
