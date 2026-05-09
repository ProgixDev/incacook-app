import 'dart:async';

import 'package:get/get.dart';

import 'package:incacook/features/delivery/controllers/delivery_driver_controller.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';
import 'package:incacook/features/orders/data/order_mock_data.dart';
import 'package:incacook/core/models/order_detail.dart';

/// Mocks an incoming-order dispatcher. While the driver is online and has no
/// active job, schedules a fake order to "arrive" after [_delay] and exposes
/// it via [pendingOrder]. The screen listens to that signal and presents the
/// incoming-order modal.
///
/// Real backend wiring will replace [_scheduleNext] with a websocket /
/// long-poll subscription; the rest of the contract stays the same.
class IncomingOrderController extends GetxController {
  static IncomingOrderController get instance => Get.find();

  static const Duration _delay = Duration(seconds: 8);

  final Rxn<OrderDetail> pendingOrder = Rxn<OrderDetail>();

  Timer? _timer;
  Worker? _onlineWorker;
  Worker? _jobWorker;

  @override
  void onInit() {
    super.onInit();
    _onlineWorker = ever<bool>(
      DeliveryDriverController.instance.isOnline,
      _onOnlineChanged,
    );
    //? when the active job is cleared (delivered / failed / aborted), re-arm
    //? the dispatcher so the next mock order pings a still-online driver.
    _jobWorker = ever<OrderDetail?>(
      DeliveryRouteController.instance.currentJob,
      _onJobChanged,
    );
    if (DeliveryDriverController.instance.isOnline.value) {
      _scheduleNext();
    }
  }

  void _onJobChanged(OrderDetail? job) {
    if (job == null && DeliveryDriverController.instance.isOnline.value) {
      _scheduleNext();
    }
  }

  void _onOnlineChanged(bool online) {
    if (online) {
      _scheduleNext();
    } else {
      _cancelTimer();
      pendingOrder.value = null;
    }
  }

  void _scheduleNext() {
    _cancelTimer();
    _timer = Timer(_delay, _emit);
  }

  void _emit() {
    final driver = DeliveryDriverController.instance;
    final route = DeliveryRouteController.instance;
    //? guard against late firings — if the driver went offline or accepted a
    //? different job between scheduling and now, do nothing.
    if (!driver.isOnline.value || route.order != null) return;
    pendingOrder.value = OrderMockData.demoOrder();
  }

  /// Called by the screen after the modal closes (either declined, timed out,
  /// or accepted). Clears the pending signal; for decline / timeout, re-arms
  /// the next mock dispatch so testing can iterate.
  void resolve({required bool accepted}) {
    pendingOrder.value = null;
    if (!accepted && DeliveryDriverController.instance.isOnline.value) {
      _scheduleNext();
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void onClose() {
    _cancelTimer();
    _onlineWorker?.dispose();
    _jobWorker?.dispose();
    super.onClose();
  }
}
