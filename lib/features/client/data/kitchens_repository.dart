import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/kitchen.dart';
import 'package:incacook/core/network/api_client.dart';

/// Buyer-facing "kitchens near you" feed — `GET /v1/sellers`.
///
/// Maps the backend kitchen DTO to the [Kitchen] UI model, resolving the
/// raw storage paths in `imageUrl` / `chefImageUrl` to public URLs via
/// [ApiConstants.publicImageUrl] (empty when the seller has no photo yet).
class KitchensRepository {
  KitchensRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  final ApiClient _api;

  Future<List<Kitchen>> getKitchens() async {
    final result = await _api.get<List<Kitchen>>(
      '${ApiConstants.apiPrefix}/sellers',
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => _fromDto(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }

  Kitchen _fromDto(Map<String, dynamic> dto) {
    return Kitchen(
      id: dto['id'] as String,
      name: (dto['name'] as String?) ?? '',
      imageUrl: ApiConstants.publicImageUrl(dto['imageUrl'] as String?) ?? '',
      chefImageUrl:
          ApiConstants.publicImageUrl(dto['chefImageUrl'] as String?) ?? '',
      rating: (dto['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (dto['reviewCount'] as num?)?.toInt() ?? 0,
      isVerified: (dto['isVerified'] as bool?) ?? false,
      hasFreeDelivery: (dto['hasFreeDelivery'] as bool?) ?? false,
      deliveryTime: (dto['deliveryTime'] as String?) ?? '',
      tags: (dto['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}
