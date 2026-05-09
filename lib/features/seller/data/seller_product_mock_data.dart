import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/core/models/food_listing.dart';

class SellerProductMockData {
  SellerProductMockData._();

  static List<FoodListing> demoProducts() {
    final endOfDay = DateTime.now().copyWith(hour: 22, minute: 0);
    return [
      FoodListing(
        id: 'p-polo-pizza',
        name: 'Polo Pizza',
        imageUrl: AppImages.foodTest,
        sellerName: 'Mon restaurant',
        category: SellerCategory.restaurant,
        menuCategory: 'Pizza mixte',
        rating: 4.5,
        prepMinutes: 27,
        price: 9.6,
        discountPercent: 50,
        isAvailable: true,
        isVeg: true,
        portionsLeft: 12,
        fulfillment: Fulfillment.both,
        expiresAt: endOfDay,
      ),
      FoodListing(
        id: 'p-malabar-biryani',
        name: 'Malabar Biriyani',
        imageUrl: AppImages.foodTest,
        sellerName: 'Mon restaurant',
        category: SellerCategory.restaurant,
        menuCategory: 'Dhum Biriyani',
        rating: 1.5,
        prepMinutes: 45,
        price: 16.6,
        discountPercent: 10,
        isAvailable: false,
        isVeg: true,
        portionsLeft: 0,
        fulfillment: Fulfillment.both,
        expiresAt: endOfDay,
      ),
      FoodListing(
        id: 'p-special-alpham',
        name: 'Special Alpham',
        imageUrl: AppImages.foodTest,
        sellerName: 'Mon restaurant',
        category: SellerCategory.restaurant,
        menuCategory: 'Berry Berry',
        rating: 5.0,
        prepMinutes: 35,
        price: 20.6,
        discountPercent: 0,
        isAvailable: true,
        isVeg: true,
        portionsLeft: 8,
        fulfillment: Fulfillment.both,
        expiresAt: endOfDay,
      ),
      FoodListing(
        id: 'p-meals',
        name: 'Meals',
        imageUrl: AppImages.foodTest,
        sellerName: 'Mon restaurant',
        category: SellerCategory.restaurant,
        menuCategory: 'Plat mixte',
        rating: 2.9,
        prepMinutes: 27,
        price: 12.0,
        discountPercent: 15,
        isAvailable: true,
        isVeg: true,
        portionsLeft: 10,
        fulfillment: Fulfillment.both,
        expiresAt: endOfDay,
      ),
    ];
  }
}
