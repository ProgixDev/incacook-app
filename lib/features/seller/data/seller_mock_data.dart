import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/core/models/seller_rating.dart';
import 'package:incacook/core/models/seller_profile.dart';

/// Comprehensive mock seller — every [SellerProfile] field is filled in
/// with realistic data so screens can be tested directly.
class SellerMockData {
  SellerMockData._();

  static SellerProfile demoSeller() {
    final now = DateTime.now();
    final listings = _buildListings(now);

    const stats = SellerStats(
      rating: 4.9,
      reviewCount: 312,
      mealsSold: 412,
      mealsSaved: 528,
      responseRatePercent: 98,
      criteriaRatings: [
        SellerRating(
          criterion: RatingCriterion.hygiene,
          value: 100,
          sampleCount: 142,
        ),
        SellerRating(
          criterion: RatingCriterion.foodQuality,
          value: 4.8,
          sampleCount: 312,
        ),
        SellerRating(
          criterion: RatingCriterion.packaging,
          value: 4.7,
          sampleCount: 312,
        ),
      ],
      ratingDistribution: {5: 268, 4: 32, 3: 8, 2: 3, 1: 1},
      sentimentTags: [
        SentimentTag(label: 'Délicieux', count: 154),
        SentimentTag(label: 'Authentique', count: 121),
        SentimentTag(label: 'Copieux', count: 98),
        SentimentTag(label: "À l'heure", count: 87),
        SentimentTag(label: 'Bien emballé', count: 64),
        SentimentTag(label: 'Épicé', count: 41),
      ],
    );

    return SellerProfile(
      id: 'aicha-b',
      name: 'Aïcha Benali',
      avatarUrl: AppImages.profilePic,
      category: SellerCategory.faitMaison,
      categoryTag: 'Cuisinière à domicile',
      cuisineType: 'Cuisine nord-africaine et méditerranéenne',
      distanceKm: 0.6,
      neighborhood: 'Bastille, Paris 11ème',
      prepMinMinutes: 25,
      prepMaxMinutes: 40,
      deliveryFee: 2.50,
      promoText: AppTexts.sellerProfileFirstOrderPromo,
      stats: stats,
      menuCategories: const [
        'Tout',
        'Entrées',
        'Plats',
        'Desserts',
        'Boissons',
      ],
      listings: listings,
      bio:
          "Je cuisine chaque jour pour ma famille à Bastille depuis 15 ans. "
          "Recettes héritées de ma grand-mère, ingrédients frais du marché "
          "d'Aligre, jamais de surgelés. Plutôt que de jeter mes restes, je "
          "les partage avec mes voisins à prix doux. Cuisine saine, épicée, "
          "halal, options végétariennes possibles sur demande.",
      languageCodes: const ['FR', 'AR', 'EN'],
      memberSince: DateTime(2023, 9, 12),
      lastActiveAgo: 'il y a 18 min',
      verifications: const [
        AppTexts.sellerVerificationIdentity,
        AppTexts.sellerVerificationHygieneCharter,
        AppTexts.sellerVerificationPhone,
        AppTexts.sellerVerificationAddress,
      ],
      recentReviews: const [
        SellerReview(
          authorName: 'Marie D.',
          avatarUrl: AppImages.profilePic,
          rating: 5,
          body:
              "Tajine d'exception, vraiment comme à la maison. Aïcha "
              "est adorable, on sent l'amour dans chaque plat.",
          timeAgoLabel: 'il y a 2 jours',
          helpfulCount: 24,
        ),
        SellerReview(
          authorName: 'Karim B.',
          avatarUrl: AppImages.profilePic,
          rating: 5,
          body:
              "Portions généreuses, livraison à l'heure, emballage soigné. "
              "Ma cantine du week-end depuis 3 mois.",
          timeAgoLabel: 'il y a 5 jours',
          helpfulCount: 17,
        ),
        SellerReview(
          authorName: 'Sophie L.',
          avatarUrl: AppImages.profilePic,
          rating: 4,
          body:
              "Très bon, juste un poil trop épicé pour mes enfants. Aïcha a "
              "proposé une version douce pour la prochaine commande, top.",
          timeAgoLabel: 'il y a 1 semaine',
          helpfulCount: 9,
        ),
        SellerReview(
          authorName: 'Hugo M.',
          avatarUrl: AppImages.profilePic,
          rating: 5,
          body:
              "La pastilla est une tuerie. Saveurs équilibrées, présentation "
              "soignée. Je recommande à 100%.",
          timeAgoLabel: 'il y a 2 semaines',
          helpfulCount: 31,
        ),
        SellerReview(
          authorName: 'Camille P.',
          avatarUrl: AppImages.profilePic,
          rating: 5,
          body:
              "Cuisine maison authentique, prix très raisonnables. Bonne "
              "communication via le chat avant la commande.",
          timeAgoLabel: 'il y a 3 semaines',
          helpfulCount: 12,
        ),
      ],
      location: const MapPoint(lng: 2.3692, lat: 48.8532),
      deliveryRadiusKm: 3,
      availabilitySchedule: 'Lun–Sam · 18h–22h',
    );
  }

  static List<FoodListing> _buildListings(DateTime now) {
    const sellerName = 'Aïcha Benali';
    return [
      FoodListing(
        id: 'sg-1',
        name: 'Couscous royal aux 7 légumes',
        imageUrl: AppImages.foodTest,
        sellerName: sellerName,
        category: SellerCategory.faitMaison,
        cuisineType: CuisineType.orientale,
        dishType: DishType.plat,
        distanceKm: 0.6,
        rating: 4.9,
        reviewCount: 48,
        portionsLeft: 3,
        fulfillment: Fulfillment.both,
        originalPrice: 9.00,
        price: 5.50,
        expiresAt: now.add(const Duration(hours: 2)),
        dietaryTags: const [DietaryTag.halal],
        allergens: const [Allergen.gluten, Allergen.celeri],
      ),
      FoodListing(
        id: 'sg-2',
        name: 'Pastilla au poulet et amandes',
        imageUrl: AppImages.foodTest,
        sellerName: sellerName,
        category: SellerCategory.faitMaison,
        cuisineType: CuisineType.orientale,
        dishType: DishType.plat,
        distanceKm: 0.6,
        rating: 4.9,
        reviewCount: 31,
        portionsLeft: 2,
        fulfillment: Fulfillment.both,
        originalPrice: 8.00,
        price: 4.50,
        expiresAt: now.add(const Duration(hours: 4)),
        dietaryTags: const [DietaryTag.halal],
        allergens: const [
          Allergen.gluten,
          Allergen.oeufs,
          Allergen.fruitsACoque,
        ],
      ),
      FoodListing(
        id: 'sg-3',
        name: 'Salade Mechouia',
        imageUrl: AppImages.foodTest,
        sellerName: sellerName,
        category: SellerCategory.faitMaison,
        cuisineType: CuisineType.orientale,
        dishType: DishType.entree,
        distanceKm: 0.6,
        rating: 4.7,
        reviewCount: 22,
        portionsLeft: 5,
        fulfillment: Fulfillment.both,
        originalPrice: 4.50,
        price: 2.50,
        expiresAt: now.add(const Duration(hours: 3)),
        dietaryTags: const [DietaryTag.vegan, DietaryTag.glutenFree],
        allergens: const [],
      ),
      FoodListing(
        id: 'sg-4',
        name: 'Chorba beïda',
        imageUrl: AppImages.foodTest,
        sellerName: sellerName,
        category: SellerCategory.faitMaison,
        cuisineType: CuisineType.orientale,
        dishType: DishType.entree,
        distanceKm: 0.6,
        rating: 4.8,
        reviewCount: 18,
        portionsLeft: 4,
        fulfillment: Fulfillment.both,
        originalPrice: 3.50,
        price: 2.00,
        expiresAt: now.add(const Duration(hours: 5)),
        dietaryTags: const [DietaryTag.halal],
        allergens: const [Allergen.gluten, Allergen.oeufs, Allergen.lait],
      ),
      FoodListing(
        id: 'sg-5',
        name: 'Briouates aux amandes',
        imageUrl: AppImages.foodTest,
        sellerName: sellerName,
        category: SellerCategory.faitMaison,
        cuisineType: CuisineType.orientale,
        dishType: DishType.dessert,
        distanceKm: 0.6,
        rating: 5.0,
        reviewCount: 41,
        portionsLeft: 6,
        fulfillment: Fulfillment.both,
        originalPrice: 5.00,
        price: 3.00,
        expiresAt: now.add(const Duration(hours: 6)),
        dietaryTags: const [DietaryTag.halal, DietaryTag.vegan],
        allergens: const [Allergen.gluten, Allergen.fruitsACoque],
      ),
      FoodListing(
        id: 'sg-6',
        name: 'Méfouf aux raisins',
        imageUrl: AppImages.foodTest,
        sellerName: sellerName,
        category: SellerCategory.faitMaison,
        cuisineType: CuisineType.orientale,
        dishType: DishType.dessert,
        distanceKm: 0.6,
        rating: 4.6,
        reviewCount: 14,
        portionsLeft: 0,
        fulfillment: Fulfillment.pickup,
        originalPrice: 4.00,
        price: 2.50,
        expiresAt: now.add(const Duration(hours: 7)),
        dietaryTags: const [DietaryTag.vegan],
        allergens: const [Allergen.gluten],
      ),
    ];
  }
}
