import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/core/models/seller_rating.dart';

/// Aggregate metrics derived from orders and reviews. On the backend these
/// live in a stats view / cached projection — they are NOT canonical
/// columns on the seller record. Bundled here so consumers pull all the
/// "summary numbers" together.
class SellerStats {
  const SellerStats({
    required this.rating,
    required this.reviewCount,
    required this.mealsSold,
    required this.mealsSaved,
    required this.responseRatePercent,
    required this.criteriaRatings,
    required this.ratingDistribution,
    required this.sentimentTags,
  });

  /// Overall average rating (0..5).
  final double rating;
  final int reviewCount;
  final int mealsSold;
  /// Bookmarks/favorites — listings the seller has had saved by buyers.
  final int mealsSaved;
  /// 0..100, percent of orders the seller responds to within SLA.
  final int responseRatePercent;
  /// Per-criterion ratings (hygiene / food quality / packaging).
  final List<SellerRating> criteriaRatings;
  /// Stars (1..5) → review count for that bucket.
  final Map<int, double> ratingDistribution;
  /// Most-mentioned tags from review text.
  final List<SentimentTag> sentimentTags;
}

/// Canonical seller record + denormalized loads for the buyer-facing
/// profile screen.
///
/// Field groups:
/// - **Identity**: id, name, avatarUrl, category, categoryTag,
///   cuisineType, bio
/// - **Service**: neighborhood, location, deliveryRadiusKm, deliveryFee,
///   prepMinMinutes, prepMaxMinutes
/// - **Profile metadata**: languageCodes, memberSince, availabilitySchedule,
///   verifications, promoText
/// - **Aggregates**: [stats] (separate object — derived, not canonical)
/// - **Buyer context**: distanceKm (depends on buyer location),
///   lastActiveAgo (computed from last_seen_at)
/// - **Denormalized loads**: menuCategories, listings, recentReviews —
///   fetched alongside the profile in real life, separate API calls.
class SellerProfile {
  const SellerProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.category,
    required this.categoryTag,
    required this.cuisineType,
    required this.bio,
    required this.neighborhood,
    required this.location,
    required this.deliveryRadiusKm,
    required this.deliveryFee,
    required this.prepMinMinutes,
    required this.prepMaxMinutes,
    required this.languageCodes,
    required this.memberSince,
    required this.availabilitySchedule,
    required this.verifications,
    required this.stats,
    this.distanceKm = 0,
    this.lastActiveAgo = '',
    this.menuCategories = const [],
    this.listings = const [],
    this.recentReviews = const [],
    this.promoText,
  });

  // --- Identity -------------------------------------------------------------
  final String id;
  final String name;
  final String avatarUrl;
  final SellerCategory category;
  final String categoryTag;
  final String cuisineType;
  final String bio;

  // --- Service --------------------------------------------------------------
  final String neighborhood;
  final MapPoint location;
  final double deliveryRadiusKm;
  final double deliveryFee;
  final int prepMinMinutes;
  final int prepMaxMinutes;

  // --- Profile metadata -----------------------------------------------------
  final List<String> languageCodes;
  final DateTime memberSince;
  final String availabilitySchedule;
  final List<String> verifications;
  final String? promoText;

  // --- Aggregates -----------------------------------------------------------
  final SellerStats stats;

  // --- Buyer context (transient) -------------------------------------------
  final double distanceKm;
  final String lastActiveAgo;

  // --- Denormalized loads ---------------------------------------------------
  final List<String> menuCategories;
  final List<FoodListing> listings;
  final List<SellerReview> recentReviews;
}

class SentimentTag {
  const SentimentTag({required this.label, required this.count});

  final String label;
  final int count;
}

class SellerReview {
  const SellerReview({
    required this.authorName,
    required this.avatarUrl,
    required this.rating,
    required this.body,
    required this.timeAgoLabel,
    required this.helpfulCount,
  });

  final String authorName;
  final String avatarUrl;
  final int rating;
  final String body;
  final String timeAgoLabel;
  final int helpfulCount;
}
