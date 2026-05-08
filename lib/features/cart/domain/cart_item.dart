import 'package:incacook/features/client/domain/food_listing.dart';
import 'package:incacook/features/orders/domain/product_add_on.dart';

/// One line in the cart. Two buys of the same dish with different options
/// produce two separate line items so their state stays independent.
class CartItem {
  const CartItem({
    required this.id,
    required this.listing,
    required this.quantity,
    required this.selectedAddOns,
    required this.note,
    this.isAvailable = true,
  });

  final String id;
  final FoodListing listing;
  final int quantity;
  final List<ProductAddOn> selectedAddOns;
  final String note;
  final bool isAvailable;

  double get unitPrice =>
      listing.price + selectedAddOns.fold(0.0, (sum, a) => sum + a.priceDelta);

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({int? quantity, bool? isAvailable}) {
    return CartItem(
      id: id,
      listing: listing,
      quantity: quantity ?? this.quantity,
      selectedAddOns: selectedAddOns,
      note: note,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
