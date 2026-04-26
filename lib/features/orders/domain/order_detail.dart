import 'package:homemade/features/cart/domain/cart_item.dart';
import 'package:homemade/features/orders/domain/delivery_details.dart';
import 'package:homemade/features/orders/domain/fulfillment_options.dart';
import 'package:homemade/features/orders/domain/order_stage.dart';
import 'package:homemade/features/orders/domain/payment_method.dart';
import 'package:homemade/features/seller/domain/seller_profile.dart';

/// Snapshot of a single placed order. Bundles every piece of data the
/// post-checkout screens need (confirmation, tracking, history).
///
/// [deliveryDetails] is non-null only when [fulfillment.choice] is
/// [FulfillmentChoice.delivery]; pickup orders carry a null here.
class OrderDetail {
  const OrderDetail({
    required this.id,
    required this.orderNumber,
    required this.placedAt,
    required this.stage,
    required this.seller,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.fulfillment,
    required this.fulfillmentOptions,
    required this.paymentMethod,
    this.deliveryDetails,
    this.deliverer,
    this.expectedAt,
    this.note,
  });

  final String id;
  final String orderNumber;
  final DateTime placedAt;
  final OrderStage stage;
  final SellerProfile seller;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final FulfillmentSelection fulfillment;
  final FulfillmentOptions fulfillmentOptions;
  final PaymentMethod paymentMethod;
  final DeliveryDetails? deliveryDetails;
  final DelivererInfo? deliverer;
  final DateTime? expectedAt;
  final String? note;

  bool get isDelivery => fulfillment.choice == FulfillmentChoice.delivery;
  bool get isPickup => fulfillment.choice == FulfillmentChoice.pickup;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
}

/// Person delivering an order. Optional on [OrderDetail] — only set once
/// a courier has been assigned (i.e. stage ≥ [OrderStage.onTheWay]).
class DelivererInfo {
  const DelivererInfo({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.rating,
    required this.completedDeliveries,
    required this.vehicleType,
    this.licensePlate,
    this.phoneNumber,
  });

  final String id;
  final String name;
  final String avatarPath;
  final double rating;
  final int completedDeliveries;
  final String vehicleType;
  final String? licensePlate;
  final String? phoneNumber;
}
