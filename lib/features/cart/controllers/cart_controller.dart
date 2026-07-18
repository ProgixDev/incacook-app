import 'package:get/get.dart';
import 'package:ulid/ulid.dart';
import 'package:incacook/core/models/cart_item.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/core/utils/log.dart';

/// Session-scoped cart state. Items are locked to a single seller: trying to
/// add from another seller surfaces a conflict that the caller resolves via
/// [SellerConflictResolver], typically by prompting the user to clear the cart.
class CartController extends GetxController {
  static CartController get instance => Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController(), permanent: true);

  final RxList<CartItem> items = <CartItem>[].obs;

  int _sequence = 0;

  /// A stable key for one checkout attempt against the cart's current
  /// contents. Lazily minted on first read and reused across retries (e.g.
  /// a failed payment → "choose another method" → pay again constructs a
  /// new `PaymentProcessingScreen`) so the server's create-order dedup can
  /// recognize a retry as the same attempt instead of creating a duplicate
  /// order. Any cart mutation invalidates it, since that's a genuinely new
  /// attempt the server should not deduplicate against the old one.
  String? _checkoutIdempotencyKey;

  String get checkoutIdempotencyKey =>
      _checkoutIdempotencyKey ??= Ulid().toString();

  void _invalidateCheckoutKey() => _checkoutIdempotencyKey = null;

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

  /// Adds [draft] to the cart. The caller passes a [CartItem] with an
  /// empty `id` — the controller assigns a sequence-based id on insert.
  /// If the cart already contains items from a different seller,
  /// [resolveConflict] is awaited — return `true` to clear and proceed,
  /// `false` to cancel.
  ///
  /// Returns `true` if the item was added, `false` if the caller cancelled.
  Future<bool> tryAdd(
    CartItem draft, {
    required Future<bool> Function(String currentSellerName) resolveConflict,
  }) async {
    if (!_sameSeller(draft.listing)) {
      final confirmed = await resolveConflict(sellerName!);
      if (!confirmed) return false;
      clear();
    }
    _addInternal(draft);
    return true;
  }

  void _addInternal(CartItem draft) {
    _invalidateCheckoutKey();
    _sequence++;
    items.add(
      CartItem(
        id: '${draft.listing.id}-$_sequence',
        listing: draft.listing,
        quantity: draft.quantity,
        selectedAddOns: List.unmodifiable(draft.selectedAddOns),
        note: draft.note,
      ),
    );
  }

  void incrementQuantity(String lineId) {
    final index = items.indexWhere((i) => i.id == lineId);
    if (index == -1) return;
    final item = items[index];
    if (item.quantity >= item.listing.portionsLeft) return;
    _invalidateCheckoutKey();
    items[index] = item.copyWith(quantity: item.quantity + 1);
    items.refresh();
    _logTotals();
  }

  /// Minus button. Decrements while quantity > 1; at quantity 1 the item is
  /// removed from the cart entirely. There is deliberately NO min-1 clamp here
  /// — a minimum of 1 only applies *before* an item is added to the cart. Once
  /// in the cart, quantity 0 means "delete". Totals + the cart badge recompute
  /// immediately because they derive from the reactive [items] list.
  void decrementQuantity(String lineId) {
    final index = items.indexWhere((i) => i.id == lineId);
    if (index == -1) return;
    final item = items[index];
    _invalidateCheckoutKey();
    if (item.quantity <= 1) {
      logInfo('[Cart] remove item=$lineId');
      items.removeAt(index);
    } else {
      logInfo('[Cart] decrease item=$lineId oldQty=${item.quantity}');
      items[index] = item.copyWith(quantity: item.quantity - 1);
    }
    items.refresh();
    _logTotals();
  }

  void removeItem(String lineId) {
    logInfo('[Cart] remove item=$lineId');
    _invalidateCheckoutKey();
    items.removeWhere((i) => i.id == lineId);
    items.refresh();
    _logTotals();
  }

  /// Debug trace of the cart aggregate after every mutation. `total` mirrors
  /// the subtotal here — delivery + service fees are added downstream at the
  /// order-summary / payment step, not in this session cart.
  void _logTotals() {
    logInfo(
      '[Cart] count=$itemCount subtotal=${subtotal.toStringAsFixed(2)} '
      'total=${subtotal.toStringAsFixed(2)}',
    );
  }

  void markUnavailable(String lineId, {bool unavailable = true}) {
    final index = items.indexWhere((i) => i.id == lineId);
    if (index == -1) return;
    items[index] = items[index].copyWith(isAvailable: !unavailable);
  }

  void clear() {
    _invalidateCheckoutKey();
    items.clear();
  }
}
