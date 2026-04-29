import 'package:get/get.dart';

class DeliveryDriverController extends GetxController {
  static DeliveryDriverController get instance => Get.find();

  //? in-memory only for now — persistence comes when the UI is locked.
  final RxBool isOnline = false.obs;

  void toggle() => isOnline.value = !isOnline.value;
}
