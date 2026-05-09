import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/models/address.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/models/cart_item.dart';
import 'package:incacook/core/models/delivery_details.dart';
import 'package:incacook/core/models/fulfillment_options.dart';
import 'package:incacook/core/models/order_detail.dart';
import 'package:incacook/core/enums/order_stage.dart';
import 'package:incacook/core/models/payment_method.dart';
import 'package:incacook/core/models/product_add_on.dart';
import 'package:incacook/features/seller/data/seller_mock_data.dart';

/// Comprehensive mock order — every [OrderDetail] field is filled in.
/// Built from [SellerMockData.demoSeller] so seller/listing references stay
/// consistent across the app.
class OrderMockData {
  OrderMockData._();

  static OrderDetail demoOrder() {
    final now = DateTime.now();
    final seller = SellerMockData.demoSeller();

    //* lines reference the seller's own listings so cards render with
    //* matching images / dietary tags / cuisine info.
    final couscous = seller.listings[0];
    final pastilla = seller.listings[1];
    final briouates = seller.listings[4];

    const extraSpicy = ProductAddOn(
      id: 'addon-extra-spicy',
      label: 'Plus épicé',
      priceDelta: 0.0,
    );
    const extraOlive = ProductAddOn(
      id: 'addon-extra-olive',
      label: 'Olives en plus',
      priceDelta: 0.50,
    );

    final items = <CartItem>[
      CartItem(
        id: 'line-1',
        listing: couscous,
        quantity: 2,
        selectedAddOns: const [extraOlive],
        note: 'Pas trop épicé pour les enfants svp.',
      ),
      CartItem(
        id: 'line-2',
        listing: pastilla,
        quantity: 1,
        selectedAddOns: const [extraSpicy],
        note: '',
      ),
      CartItem(
        id: 'line-3',
        listing: briouates,
        quantity: 3,
        selectedAddOns: const [],
        note: '',
      ),
    ];

    final subtotal = items.fold<double>(0, (sum, i) => sum + i.lineTotal);
    const deliveryFee = 2.50;
    const serviceFee = 0.50;
    final total = subtotal + deliveryFee + serviceFee;

    return OrderDetail(
      id: 'ord-2024-04-26-001',
      orderNumber: 'A4521',
      placedAt: now.subtract(const Duration(minutes: 18)),
      stage: OrderStage.onTheWay,
      seller: seller,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      total: total,
      fulfillment: const FulfillmentSelection(
        choice: FulfillmentChoice.delivery,
        fee: deliveryFee,
      ),
      fulfillmentOptions: const FulfillmentOptions(
        deliveryAvailable: true,
        deliveryMinMinutes: 25,
        deliveryMaxMinutes: 40,
        deliveryFee: deliveryFee,
        pickupAvailable: true,
        pickupNeighborhood: 'Bastille, Paris 11ème',
      ),
      paymentMethod: const SavedCardPaymentMethod(
        id: 'card-1',
        last4: '4242',
        expiry: '12/26',
        brand: 'Visa',
      ),
      deliveryDetails: const DeliveryDetails(
        address: Address(
          id: 'addr-home',
          type: SavedAddressType.home,
          fullAddress: '12 rue Saint-Sabin',
          city: 'Paris',
          postalCode: '75011',
          coordinate: MapPoint(lng: 2.3719, lat: 48.8587),
        ),
        instructions: 'Code 1234, 3e étage gauche. Sonnez fort.',
        timing: DeliveryTiming.asap,
      ),
      deliverer: const DelivererInfo(
        id: 'rider-jd',
        name: 'Jean Dupont',
        avatarUrl: AppImages.profilePic,
        rating: 4.9,
        completedDeliveries: 1284,
        vehicleType: 'Vélo électrique',
        licensePlate: '7821-BV',
        phoneNumber: '+33 6 12 34 56 78',
      ),
      expectedAt: now.add(const Duration(minutes: 27)),
      note: 'Pas trop épicé pour les enfants svp. Merci !',
    );
  }
}
