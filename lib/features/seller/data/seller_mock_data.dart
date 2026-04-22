import 'package:latlong2/latlong.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/core/enums/food_enums.dart';
import 'package:vinted_v2/core/enums/order_enums.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';
import 'package:vinted_v2/features/seller/domain/performance_metric.dart';
import 'package:vinted_v2/features/seller/domain/seller_profile.dart';

class SellerMockData {
  SellerMockData._();

  static SellerProfile demoSeller() {
    final now = DateTime.now();
    return SellerProfile(
      id: 'fatima-k',
      name: 'Fatima K.',
      avatarPath: AppImages.profilePic,
      category: SellerCategory.faitMaison,
      categoryTag: 'Fait maison',
      cuisineType: 'Cuisine nord-africaine',
      rating: 4.9,
      reviewCount: 247,
      distanceKm: 0.4,
      neighborhood: 'Bastille, Paris 11ème',
      prepMinMinutes: 30,
      prepMaxMinutes: 45,
      deliveryFee: 2.50,
      responseRatePercent: 98,
      mealsSold: 247,
      mealsSaved: 312,
      promoText: AppTexts.sellerProfileFirstOrderPromo,
      performance: const [
        PerformanceMetric(
          type: PerformanceMetricType.hygiene,
          percent: 88,
        ),
        PerformanceMetric(
          type: PerformanceMetricType.punctuality,
          percent: 92,
        ),
        PerformanceMetric(
          type: PerformanceMetricType.accuracy,
          percent: 100,
        ),
        PerformanceMetric(
          type: PerformanceMetricType.communication,
          percent: 88,
        ),
        PerformanceMetric(
          type: PerformanceMetricType.foodQuality,
          percent: 96,
        ),
      ],
      menuCategories: const [
        'Tout',
        'Plats',
        'Desserts',
        'Entrées',
        'Boissons',
      ],
      listings: [
        FoodListing(
          id: 's1',
          name: 'Tajine poulet',
          imagePath: AppImages.foodTest,
          sellerName: 'Fatima K.',
          category: SellerCategory.faitMaison,
          distanceKm: 0.4,
          rating: 4.9,
          reviewCount: 24,
          portionsLeft: 3,
          fulfillment: Fulfillment.both,
          originalPrice: 7.00,
          price: 3.50,
          expiresAt: now.add(const Duration(hours: 2)),
        ),
        FoodListing(
          id: 's2',
          name: 'Chorba maison',
          imagePath: AppImages.foodTest,
          sellerName: 'Fatima K.',
          category: SellerCategory.faitMaison,
          distanceKm: 0.4,
          rating: 4.8,
          reviewCount: 18,
          portionsLeft: 5,
          fulfillment: Fulfillment.both,
          originalPrice: 3.50,
          price: 2.00,
          expiresAt: now.add(const Duration(hours: 4)),
        ),
        FoodListing(
          id: 's3',
          name: 'Salade marocaine',
          imagePath: AppImages.foodTest,
          sellerName: 'Fatima K.',
          category: SellerCategory.faitMaison,
          distanceKm: 0.4,
          rating: 4.7,
          reviewCount: 12,
          portionsLeft: 4,
          fulfillment: Fulfillment.both,
          originalPrice: 4.00,
          price: 2.50,
          expiresAt: now.add(const Duration(hours: 3)),
        ),
        FoodListing(
          id: 's4',
          name: 'Baklava',
          imagePath: AppImages.foodTest,
          sellerName: 'Fatima K.',
          category: SellerCategory.faitMaison,
          distanceKm: 0.4,
          rating: 5.0,
          reviewCount: 33,
          portionsLeft: 6,
          fulfillment: Fulfillment.both,
          originalPrice: 5.00,
          price: 3.00,
          expiresAt: now.add(const Duration(hours: 5)),
        ),
      ],
      bio:
          "Je cuisine chaque jour pour ma famille à Bastille depuis 15 ans. Plutôt que de jeter mes restes, je partage avec mes voisins à prix doux. Une cuisine saine, épicée, et pleine d'amour.",
      languageCodes: const ['FR', 'DZ'],
      memberSince: DateTime(2024, 3, 1),
      lastActiveAgo: 'il y a 2h',
      verifications: const [
        AppTexts.sellerVerificationIdentity,
        AppTexts.sellerVerificationHygieneCharter,
        AppTexts.sellerVerificationPhone,
        AppTexts.sellerVerificationAddress,
      ],
      ratingDistribution: const {5: 89, 4: 8, 3: 2, 2: 1, 1: 0},
      sentimentTags: const [
        SentimentTag(label: 'Délicieux', count: 82),
        SentimentTag(label: 'Copieux', count: 47),
        SentimentTag(label: 'Épicé', count: 34),
        SentimentTag(label: "À l'heure", count: 98),
      ],
      recentReviews: const [
        SellerReview(
          authorName: 'Marie D.',
          avatarPath: AppImages.profilePic,
          rating: 5,
          body:
              'Excellent tajine, vraiment comme à la maison. Fatima est adorable en plus !',
          timeAgoLabel: 'il y a 2 jours',
          helpfulCount: 12,
        ),
        SellerReview(
          authorName: 'Karim B.',
          avatarPath: AppImages.profilePic,
          rating: 5,
          body: 'Portions généreuses, livraison à l\'heure. Top.',
          timeAgoLabel: 'il y a 5 jours',
          helpfulCount: 7,
        ),
      ],
      location: const LatLng(48.8532, 2.3692),
      deliveryRadiusKm: 3,
      availabilitySchedule: 'Lun–Ven · 18h–22h',
    );
  }
}
