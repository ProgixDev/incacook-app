import 'package:incacook/features/client/domain/food_listing.dart';
import 'package:incacook/features/orders/domain/product_add_on.dart';

class OrderCustomization {
  const OrderCustomization({
    required this.listing,
    required this.quantity,
    required this.selectedAddOns,
    required this.note,
    required this.totalPrice,
  });

  final FoodListing listing;
  final int quantity;
  final List<ProductAddOn> selectedAddOns;
  final String note;
  final double totalPrice;
}
