import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/styles/loaders.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;

  //? initialize the network manager and setup a stream to cpntinually check the network status
  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  //? update connection status based on changes in connectivity and show a relevant popup for no internet connection
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _connectionStatus.value = result.first;
    if (_connectionStatus.value == ConnectivityResult.none) {
      CustomLoaders.warningSnackBar(title: 'No Internet Connection');
    }
  }

  //? check the internet connection status
  //? returns true if connected and false if not
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }

  //? dispose or close the active connectivity stream
  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }
}
