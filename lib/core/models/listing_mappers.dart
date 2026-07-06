import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/core/models/listing.dart';

/// Adapts a backend [Listing] (from `GET /v1/listings`) to the UI-facing
/// [FoodListing] used by cards, the map pin, and the map sheet. Resolves the
/// first storage image path to a fetchable URL; falls back to a placeholder
/// when none. Shared by the buyer feed and the map so there's a single
/// mapping (no per-screen drift).
extension ListingToFoodListing on Listing {
  FoodListing toFoodListing() => FoodListing(
        id: id,
        name: name,
        imageUrl: imageUrls.isNotEmpty
            ? (ApiConstants.publicImageUrl(imageUrls.first) ?? AppImages.foodTest)
            : AppImages.foodTest,
        // Fall back to a generic cook name (never ''), so the order summary
        // shows a name instead of letting the category label stand in (ISSUE-13).
        sellerName: (sellerName == null || sellerName!.trim().isEmpty)
            ? AppTexts.productSellerFallbackName
            : sellerName!,
        category: category,
        price: priceCents / 100,
        portionsLeft: portionsLeft ?? 0,
        fulfillment: fulfillment,
        expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 365)),
        distanceKm: distanceKm ?? 0,
        rating: rating ?? 0,
        reviewCount: reviewCount ?? 0,
        originalPrice:
            originalPriceCents == null ? null : originalPriceCents! / 100,
        discountPercent: discountPercent ?? 0,
        prepMinutes: prepMinutes,
        isAvailable: isAvailable,
        isVeg: isVeg,
        menuCategory: menuCategory,
        dietaryTags: dietaryTags,
        allergens: allergens,
        otherAllergens: otherAllergens,
      );
}
