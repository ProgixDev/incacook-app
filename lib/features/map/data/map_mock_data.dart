import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/features/client/domain/food_listing.dart';
import 'package:incacook/features/map/domain/map_entry.dart';

class MapMockData {
  MapMockData._();

  /// Demo pin set anchored around 2.3522, 48.8566 (central Paris) so they
  /// fall on/near [MapController.userLocation] for the demo seed.
  static List<MapEntry> entries() {
    final now = DateTime.now();
    return [
      MapEntry(
        position: Position(2.3530, 48.8580),
        listing: FoodListing(
          id: 'm1',
          name: 'Tajine poulet olives',
          imagePath: AppImages.foodTest,
          sellerName: 'Fatima',
          category: SellerCategory.faitMaison,
          distanceKm: 0.3,
          rating: 4.9,
          reviewCount: 24,
          dietaryTags: const [DietaryTag.halal],
          portionsLeft: 4,
          fulfillment: Fulfillment.delivery,
          originalPrice: 8.00,
          price: 3.00,
          expiresAt: now.add(const Duration(hours: 2)),
        ),
      ),
      MapEntry(
        position: Position(2.3490, 48.8610),
        listing: FoodListing(
          id: 'm2',
          name: 'Lasagne maison',
          imagePath: AppImages.foodTest,
          sellerName: 'Chez Luigi',
          category: SellerCategory.traiteur,
          distanceKm: 0.8,
          rating: 4.7,
          reviewCount: 56,
          portionsLeft: 6,
          fulfillment: Fulfillment.both,
          originalPrice: 12.00,
          price: 5.50,
          expiresAt: now.add(const Duration(hours: 5)),
        ),
      ),
      MapEntry(
        position: Position(2.3580, 48.8550),
        listing: FoodListing(
          id: 'm3',
          name: 'Buddha bowl végé',
          imagePath: AppImages.foodTest,
          sellerName: 'Green Kitchen',
          category: SellerCategory.restaurant,
          distanceKm: 1.1,
          rating: 4.6,
          reviewCount: 89,
          dietaryTags: const [DietaryTag.vegan, DietaryTag.glutenFree],
          portionsLeft: 2,
          fulfillment: Fulfillment.pickup,
          originalPrice: 11.00,
          price: 4.50,
          expiresAt: now.add(const Duration(hours: 1, minutes: 30)),
        ),
      ),
      MapEntry(
        position: Position(2.3460, 48.8540),
        listing: FoodListing(
          id: 'm4',
          name: 'Soupe de légumes',
          imagePath: AppImages.foodTest,
          sellerName: 'Chez Anna',
          category: SellerCategory.traiteur,
          distanceKm: 1.0,
          rating: 4.7,
          reviewCount: 18,
          portionsLeft: 2,
          fulfillment: Fulfillment.both,
          price: 4,
          expiresAt: now.add(const Duration(hours: 1)),
        ),
      ),
      MapEntry(
        position: Position(2.3560, 48.8620),
        listing: FoodListing(
          id: 'm5',
          name: 'Quiche lorraine',
          imagePath: AppImages.foodTest,
          sellerName: 'Marc',
          category: SellerCategory.faitMaison,
          distanceKm: 0.5,
          rating: 4.8,
          reviewCount: 12,
          portionsLeft: 1,
          fulfillment: Fulfillment.pickup,
          price: 2.50,
          expiresAt: now.add(const Duration(hours: 3)),
        ),
      ),
      MapEntry(
        position: Position(2.3440, 48.8595),
        listing: FoodListing(
          id: 'm6',
          name: 'Tarte aux pommes',
          imagePath: AppImages.foodTest,
          sellerName: 'Boulangerie Paul',
          category: SellerCategory.restaurant,
          distanceKm: 0.7,
          rating: 4.6,
          reviewCount: 41,
          portionsLeft: 3,
          fulfillment: Fulfillment.pickup,
          price: 2,
          expiresAt: now.add(const Duration(hours: 4)),
        ),
      ),
    ];
  }
}
