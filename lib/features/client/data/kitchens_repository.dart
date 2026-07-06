import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/models/kitchen.dart';
import 'package:incacook/core/models/seller_profile.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/services/map/models/map_route.dart';

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

  /// Public profile for one seller (`GET /v1/sellers/:id`). Builds the UI
  /// [SellerProfile] from real data; the rich mock-only stats (per-criterion
  /// ratings, meals sold/saved, response rate, sentiment, reviews) have no
  /// backend source yet, so they come back empty/zero — the profile screen
  /// hides those sections.
  Future<SellerProfile> getSeller(String id) async {
    final result = await _api.get<SellerProfile>(
      '${ApiConstants.apiPrefix}/sellers/$id',
      decoder: (json) => _profileFromDto(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  SellerProfile _profileFromDto(Map<String, dynamic> dto) {
    final lng = (dto['lng'] as num?)?.toDouble();
    final lat = (dto['lat'] as num?)?.toDouble();
    final cuisines =
        (dto['cuisineTypes'] as List<dynamic>?)?.cast<String>() ??
            const <String>[];
    return SellerProfile(
      id: dto['id'] as String,
      name: (dto['name'] as String?) ?? '',
      avatarUrl: ApiConstants.publicImageUrl(dto['avatarUrl'] as String?) ?? '',
      category: _categoryFromWire(dto['category'] as String?),
      categoryTag: (dto['categoryTag'] as String?) ?? '',
      cuisineType: cuisines.join(', '),
      bio: (dto['bio'] as String?) ?? '',
      neighborhood: (dto['neighborhood'] as String?) ?? '',
      location: MapPoint(lng: lng ?? 0, lat: lat ?? 0),
      deliveryRadiusKm: (dto['deliveryRadiusKm'] as num?)?.toDouble() ?? 0,
      deliveryFee: ((dto['deliveryFeeCents'] as num?)?.toDouble() ?? 0) / 100,
      prepMinMinutes: (dto['prepMinMinutes'] as num?)?.toInt() ?? 0,
      prepMaxMinutes: (dto['prepMaxMinutes'] as num?)?.toInt() ?? 0,
      languageCodes:
          (dto['languageCodes'] as List<dynamic>?)?.cast<String>() ?? const [],
      memberSince:
          DateTime.tryParse(dto['memberSince'] as String? ?? '') ??
              DateTime.now(),
      availabilitySchedule: (dto['availabilitySchedule'] as String?) ?? '',
      verifications:
          (dto['verifications'] as List<dynamic>?)?.cast<String>() ?? const [],
      stats: SellerStats(
        rating: (dto['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (dto['reviewCount'] as num?)?.toInt() ?? 0,
        mealsSold: 0,
        mealsSaved: 0,
        responseRatePercent: 0,
        criteriaRatings: const [],
        ratingDistribution: const {},
        sentimentTags: const [],
      ),
      promoText: dto['promoText'] as String?,
    );
  }

  SellerCategory _categoryFromWire(String? wire) {
    switch (wire) {
      case 'TRAITEUR':
        return SellerCategory.traiteur;
      case 'RESTAURANT':
        return SellerCategory.restaurant;
      case 'FAIT_MAISON':
      default:
        return SellerCategory.faitMaison;
    }
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
