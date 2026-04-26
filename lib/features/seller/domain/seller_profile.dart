import 'package:latlong2/latlong.dart';
import 'package:homemade/core/enums/food_enums.dart';
import 'package:homemade/features/home/domain/food_listing.dart';
import 'package:homemade/features/seller/domain/seller_rating.dart';

class SellerProfile {
  const SellerProfile({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.category,
    required this.categoryTag,
    required this.cuisineType,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.neighborhood,
    required this.prepMinMinutes,
    required this.prepMaxMinutes,
    required this.deliveryFee,
    required this.responseRatePercent,
    required this.mealsSold,
    required this.mealsSaved,
    required this.ratings,
    required this.menuCategories,
    required this.listings,
    required this.bio,
    required this.languageCodes,
    required this.memberSince,
    required this.lastActiveAgo,
    required this.verifications,
    required this.ratingDistribution,
    required this.sentimentTags,
    required this.recentReviews,
    required this.location,
    required this.deliveryRadiusKm,
    required this.availabilitySchedule,
    this.promoText,
  });

  final String id;
  final String name;
  final String avatarPath;
  final SellerCategory category;
  final String categoryTag;
  final String cuisineType;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final String neighborhood;
  final int prepMinMinutes;
  final int prepMaxMinutes;
  final double deliveryFee;
  final int responseRatePercent;
  final int mealsSold;
  final int mealsSaved;
  final List<SellerRating> ratings;
  final List<String> menuCategories;
  final List<FoodListing> listings;
  final String bio;
  final List<String> languageCodes;
  final DateTime memberSince;
  final String lastActiveAgo;
  final List<String> verifications;
  final Map<int, double> ratingDistribution;
  final List<SentimentTag> sentimentTags;
  final List<SellerReview> recentReviews;
  final LatLng location;
  final double deliveryRadiusKm;
  final String availabilitySchedule;
  final String? promoText;
}

class SentimentTag {
  const SentimentTag({required this.label, required this.count});

  final String label;
  final int count;
}

class SellerReview {
  const SellerReview({
    required this.authorName,
    required this.avatarPath,
    required this.rating,
    required this.body,
    required this.timeAgoLabel,
    required this.helpfulCount,
  });

  final String authorName;
  final String avatarPath;
  final int rating;
  final String body;
  final String timeAgoLabel;
  final int helpfulCount;
}
