import 'package:get/get.dart';
import 'package:homemade/features/orders/domain/order_stage.dart';

class OrderTrackingController extends GetxController {
  static OrderTrackingController get instance => Get.find();

  final Rx<OrderStage> stage = OrderStage.onTheWay.obs;

  //? dynamic in a real app — stays constant here for the demo
  final RxInt etaMinutes = 47.obs;

  void setStage(OrderStage next) => stage.value = next;
}
