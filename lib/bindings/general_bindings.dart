import 'package:get/get.dart';
import 'package:incacook/core/controllers/theme_controller.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/services/map/google_directions_client.dart';
import 'package:incacook/core/services/map/google_places_client.dart';
import 'package:incacook/core/services/realtime/tracking_socket_client.dart';
import 'package:incacook/core/utils/helpers/network_manager.dart';
import 'package:incacook/features/chat/data/conversations_repository.dart';
import 'package:incacook/features/chat/data/messages_repository.dart';
import 'package:incacook/features/delivery/data/deliveries_repository.dart';
import 'package:incacook/features/notifications/data/notifications_repository.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';
import 'package:incacook/features/seller/data/seller_orders_repository.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(ThemeController());
    // permanent / fenix so logout's `Get.offAll` (SmartManagement.full tears
    // down the route stack) can't dispose these app-wide singletons. Without
    // it, a second signup after logout re-enters the address picker, whose
    // `Get.find<LocationService>()` / `Get.find<GooglePlacesClient>()` throw
    // once disposed — and in release a thrown build() renders a grey
    // ErrorWidget box where the picker should be. (client_home / map_controller
    // already re-register LocationService defensively for the same reason.)
    Get.put(LocationService(), permanent: true);
    Get.lazyPut(() => GoogleDirectionsClient(), fenix: true);
    Get.lazyPut(() => GooglePlacesClient(), fenix: true);
    Get.lazyPut(() => TrackingSocketClient(), fenix: true);
    Get.lazyPut(() => OrdersRepository(), fenix: true);
    Get.lazyPut(() => SellerOrdersRepository(), fenix: true);
    Get.lazyPut(() => DeliveriesRepository(), fenix: true);
    Get.lazyPut(() => MessagesRepository(), fenix: true);
    Get.lazyPut(() => ConversationsRepository(), fenix: true);
    Get.lazyPut(() => NotificationsRepository(), fenix: true);
  }
}
