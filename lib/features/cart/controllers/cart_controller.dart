import 'package:get/get.dart';
import 'package:vinted_v2/features/cart/domain/cart_line_item.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';
import 'package:vinted_v2/features/orders/domain/order_customization.dart';

/// Session-scoped cart state. Items are locked to a single seller: trying to
/// add from another seller surfaces a conflict that the caller resolves via
/// [SellerConflictResolver], typically by prompting the user to clear the cart.
class CartController extends GetxController {
  static CartController get instance =>
      Get.isRegistered<CartController>()
          ? Get.find<CartController>()
          : Get.put(CartController(), permanent: true);

  final RxList<CartLineItem> items = <CartLineItem>[].obs;

  int _sequence = 0;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.lineTotal);

  /// The seller's reference listing, used for the header block and
  /// different-seller conflict checks. Null when the cart is empty.
  FoodListing? get sellerReference =>
      items.isEmpty ? null : items.first.listing;

  String? get sellerName => sellerReference?.sellerName;

  bool _sameSeller(FoodListing listing) =>
      sellerName == null || sellerName == listing.sellerName;

  /// Adds [customization] to the cart. If the cart already contains items
  /// from a different seller, [resolveConflict] is awaited — return `true`
  /// to clear and proceed, `false` to cancel.
  ///
  /// Returns `true` if the item was added, `false` if the caller cancelled.
  Future<bool> tryAdd(
    OrderCustomization customization, {
    required Future<bool> Function(String currentSellerName) resolveConflict,
  }) async {
    final incoming = customization.listing;
    if (!_sameSeller(incoming)) {
      final confirmed = await resolveConflict(sellerName!);
      if (!confirmed) return false;
      clear();
    }
    _addInternal(customization);
    return true;
  }

  void _addInternal(OrderCustomization c) {
    _sequence++;
    items.add(
      CartLineItem(
        id: '${c.listing.id}-$_sequence',
        listing: c.listing,
        quantity: c.quantity,
        selectedAddOns: List.unmodifiable(c.selectedAddOns),
        note: c.note,
      ),
    );
  }

  void incrementQuantity(String lineId) {
    final index = items.indexWhere((i) => i.id == lineId);
    if (index == -1) return;
    final item = items[index];
    if (item.quantity >= item.listing.portionsLeft) return;
    items[index] = item.copyWith(quantity: item.quantity + 1);
  }

  void decrementQuantity(String lineId) {
    final index = items.indexWhere((i) => i.id == lineId);
    if (index == -1) return;
    final item = items[index];
    if (item.quantity <= 1) return;
    items[index] = item.copyWith(quantity: item.quantity - 1);
  }

  void removeItem(String lineId) {
    items.removeWhere((i) => i.id == lineId);
  }

  void markUnavailable(String lineId, {bool unavailable = true}) {
    final index = items.indexWhere((i) => i.id == lineId);
    if (index == -1) return;
    items[index] = items[index].copyWith(isAvailable: !unavailable);
  }

  void clear() {
    items.clear();
  }
}
