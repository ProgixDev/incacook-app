import 'package:get/get.dart';
import 'package:incacook/core/controllers/theme_controller.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/services/map/mapbox_directions_client.dart';
import 'package:incacook/core/services/map/mapbox_search_client.dart';
import 'package:incacook/core/utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(ThemeController());
    Get.put(LocationService());
    Get.lazyPut(() => MapboxDirectionsClient());
    Get.lazyPut(() => MapboxSearchClient());
  }
}
