import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/zone.dart';
import 'package:incacook/core/network/api_client.dart';

/// Repository for the public zones catalogue under `/v1/zones`.
class ZonesRepository extends GetxService {
  ZonesRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static ZonesRepository get instance => Get.find();

  final ApiClient _api;

  /// `GET /v1/zones` — public, returns the active zones ordered by
  /// `displayOrder`. Used to populate the driver signup zone picker.
  Future<List<Zone>> getActiveZones() async {
    final result = await _api.get<List<Zone>>(
      '${ApiConstants.apiPrefix}/zones',
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => Zone.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    final zones = result.data
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return zones;
  }
}
