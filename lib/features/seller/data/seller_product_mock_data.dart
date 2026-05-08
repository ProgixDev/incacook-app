import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/features/seller/domain/seller_product.dart';

class SellerProductMockData {
  SellerProductMockData._();

  static List<SellerProduct> demoProducts() => const [
    SellerProduct(
      id: 'p-polo-pizza',
      name: 'Polo Pizza',
      imagePath: AppImages.foodTest,
      category: 'Pizza mixte',
      rating: 4.5,
      prepMinutes: 27,
      price: 9.6,
      discountPercent: 50,
      isAvailable: true,
      isVeg: true,
    ),
    SellerProduct(
      id: 'p-malabar-biryani',
      name: 'Malabar Biriyani',
      imagePath: AppImages.foodTest,
      category: 'Dhum Biriyani',
      rating: 1.5,
      prepMinutes: 45,
      price: 16.6,
      discountPercent: 10,
      isAvailable: false,
      isVeg: true,
    ),
    SellerProduct(
      id: 'p-special-alpham',
      name: 'Special Alpham',
      imagePath: AppImages.foodTest,
      category: 'Berry Berry',
      rating: 5.0,
      prepMinutes: 35,
      price: 20.6,
      discountPercent: 0,
      isAvailable: true,
      isVeg: true,
    ),
    SellerProduct(
      id: 'p-meals',
      name: 'Meals',
      imagePath: AppImages.foodTest,
      category: 'Plat mixte',
      rating: 2.9,
      prepMinutes: 27,
      price: 12.0,
      discountPercent: 15,
      isAvailable: true,
      isVeg: true,
    ),
  ];
}
