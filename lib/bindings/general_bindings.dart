import 'package:get/get.dart';
import 'package:incacook/core/controllers/theme_controller.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/services/map/mapbox_directions_client.dart';
import 'package:incacook/core/services/map/mapbox_search_client.dart';
import 'package:incacook/core/services/realtime/tracking_socket_client.dart';
import 'package:incacook/core/utils/helpers/network_manager.dart';
import 'package:incacook/features/chat/data/conversations_repository.dart';
import 'package:incacook/features/chat/data/messages_repository.dart';
import 'package:incacook/features/delivery/data/deliveries_repository.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';
import 'package:incacook/features/seller/data/seller_orders_repository.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(ThemeController());
    Get.put(LocationService());
    Get.lazyPut(() => MapboxDirectionsClient());
    Get.lazyPut(() => MapboxSearchClient());
    Get.lazyPut(() => TrackingSocketClient(), fenix: true);
    Get.lazyPut(() => OrdersRepository(), fenix: true);
    Get.lazyPut(() => SellerOrdersRepository(), fenix: true);
    Get.lazyPut(() => DeliveriesRepository(), fenix: true);
    Get.lazyPut(() => MessagesRepository(), fenix: true);
    Get.lazyPut(() => ConversationsRepository(), fenix: true);
  }
}
