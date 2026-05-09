import 'dart:async';

import 'package:get/get.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/features/orders/data/order_mock_data.dart';
import 'package:incacook/core/models/order_detail.dart';
import 'package:incacook/core/enums/order_stage.dart';

class OrderTrackingController extends GetxController {
  static OrderTrackingController get instance => Get.find();

  late final OrderDetail order = OrderMockData.demoOrder();

  final Rx<OrderStage> stage = OrderStage.onTheWay.obs;

  //? dynamic in a real app — stays constant here for the demo
  final RxInt etaMinutes = 47.obs;

  late final Rx<MapPoint> driverPosition = Rx<MapPoint>(order.seller.location);

  MapPoint get destination => order.deliveryDetails!.address.coordinate!;

  Timer? _movementTimer;

  @override
  void onInit() {
    super.onInit();
    _startSimulatedMovement();
  }

  void setStage(OrderStage next) => stage.value = next;

  //* Demo-only: linearly interpolates the driver from pickup to destination
  //* over [_totalDuration]. Replace with a real position stream when
  //* live tracking lands.
  void _startSimulatedMovement() {
    const totalDuration = Duration(minutes: 5);
    const tickInterval = Duration(seconds: 2);
    final totalTicks = totalDuration.inSeconds ~/ tickInterval.inSeconds;
    final start = order.seller.location;
    final end = destination;

    var tick = 0;
    _movementTimer?.cancel();
    _movementTimer = Timer.periodic(tickInterval, (timer) {
      tick++;
      if (tick >= totalTicks) {
        driverPosition.value = end;
        timer.cancel();
        return;
      }
      final t = tick / totalTicks;
      driverPosition.value = MapPoint(
        lng: start.lng + (end.lng - start.lng) * t,
        lat: start.lat + (end.lat - start.lat) * t,
      );
    });
  }

  @override
  void onClose() {
    _movementTimer?.cancel();
    super.onClose();
  }
}
