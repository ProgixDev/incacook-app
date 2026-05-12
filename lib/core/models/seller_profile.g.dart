// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SellerStats _$SellerStatsFromJson(Map<String, dynamic> json) => _SellerStats(
  rating: (json['rating'] as num).toDouble(),
  reviewCount: (json['review_count'] as num).toInt(),
  mealsSold: (json['meals_sold'] as num).toInt(),
  mealsSaved: (json['meals_saved'] as num).toInt(),
  responseRatePercent: (json['response_rate_percent'] as num).toInt(),
  criteriaRatings: (json['criteria_ratings'] as List<dynamic>)
      .map((e) => SellerRating.fromJson(e as Map<String, dynamic>))
      .toList(),
  ratingDistribution: (json['rating_distribution'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k), (e as num).toDouble()),
  ),
  sentimentTags: (json['sentiment_tags'] as List<dynamic>)
      .map((e) => SentimentTag.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SellerStatsToJson(
  _SellerStats instance,
) => <String, dynamic>{
  'rating': instance.rating,
  'review_count': instance.reviewCount,
  'meals_sold': instance.mealsSold,
  'meals_saved': instance.mealsSaved,
  'response_rate_percent': instance.responseRatePercent,
  'criteria_ratings': instance.criteriaRatings.map((e) => e.toJson()).toList(),
  'rating_distribution': instance.ratingDistribution.map(
    (k, e) => MapEntry(k.toString(), e),
  ),
  'sentiment_tags': instance.sentimentTags.map((e) => e.toJson()).toList(),
};

_SellerProfile _$SellerProfileFromJson(Map<String, dynamic> json) =>
    _SellerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String,
      category: $enumDecode(_$SellerCategoryEnumMap, json['category']),
      categoryTag: json['category_tag'] as String,
      cuisineType: json['cuisine_type'] as String,
      bio: json['bio'] as String,
      neighborhood: json['neighborhood'] as String,
      location: MapPoint.fromJson(json['location'] as Map<String, dynamic>),
      deliveryRadiusKm: (json['delivery_radius_km'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      prepMinMinutes: (json['prep_min_minutes'] as num).toInt(),
      prepMaxMinutes: (json['prep_max_minutes'] as num).toInt(),
      languageCodes: (json['language_codes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      memberSince: DateTime.parse(json['member_since'] as String),
      availabilitySchedule: json['availability_schedule'] as String,
      verifications: (json['verifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      stats: SellerStats.fromJson(json['stats'] as Map<String, dynamic>),
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      lastActiveAgo: json['last_active_ago'] as String? ?? '',
      menuCategories:
          (json['menu_categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      listings:
          (json['listings'] as List<dynamic>?)
              ?.map((e) => FoodListing.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FoodListing>[],
      recentReviews:
          (json['recent_reviews'] as List<dynamic>?)
              ?.map((e) => SellerReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SellerReview>[],
      promoText: json['promo_text'] as String?,
    );

Map<String, dynamic> _$SellerProfileToJson(_SellerProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar_url': instance.avatarUrl,
      'category': _$SellerCategoryEnumMap[instance.category]!,
      'category_tag': instance.categoryTag,
      'cuisine_type': instance.cuisineType,
      'bio': instance.bio,
      'neighborhood': instance.neighborhood,
      'location': instance.location.toJson(),
      'delivery_radius_km': instance.deliveryRadiusKm,
      'delivery_fee': instance.deliveryFee,
      'prep_min_minutes': instance.prepMinMinutes,
      'prep_max_minutes': instance.prepMaxMinutes,
      'language_codes': instance.languageCodes,
      'member_since': instance.memberSince.toIso8601String(),
      'availability_schedule': instance.availabilitySchedule,
      'verifications': instance.verifications,
      'stats': instance.stats.toJson(),
      'distance_km': instance.distanceKm,
      'last_active_ago': instance.lastActiveAgo,
      'menu_categories': instance.menuCategories,
      'listings': instance.listings.map((e) => e.toJson()).toList(),
      'recent_reviews': instance.recentReviews.map((e) => e.toJson()).toList(),
      'promo_text': ?instance.promoText,
    };

const _$SellerCategoryEnumMap = {
  SellerCategory.faitMaison: 'FAIT_MAISON',
  SellerCategory.traiteur: 'TRAITEUR',
  SellerCategory.restaurant: 'RESTAURANT',
};

_SentimentTag _$SentimentTagFromJson(Map<String, dynamic> json) =>
    _SentimentTag(
      label: json['label'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$SentimentTagToJson(_SentimentTag instance) =>
    <String, dynamic>{'label': instance.label, 'count': instance.count};

_SellerReview _$SellerReviewFromJson(Map<String, dynamic> json) =>
    _SellerReview(
      authorName: json['author_name'] as String,
      avatarUrl: json['avatar_url'] as String,
      rating: (json['rating'] as num).toInt(),
      body: json['body'] as String,
      timeAgoLabel: json['time_ago_label'] as String,
      helpfulCount: (json['helpful_count'] as num).toInt(),
    );

Map<String, dynamic> _$SellerReviewToJson(_SellerReview instance) =>
    <String, dynamic>{
      'author_name': instance.authorName,
      'avatar_url': instance.avatarUrl,
      'rating': instance.rating,
      'body': instance.body,
      'time_ago_label': instance.timeAgoLabel,
      'helpful_count': instance.helpfulCount,
    };
