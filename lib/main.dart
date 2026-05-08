import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:incacook/app.dart';
import 'package:incacook/core/controllers/theme_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const _mapboxPublicToken = String.fromEnvironment('MAPBOX_PUBLIC_TOKEN');

void main() async {
  //* add widgets bindings
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  //? this line ensures that the firebase initialization finishes first, then initialize the design widgets

  //* init local storage
  await GetStorage.init();

  //* init French locale data for intl DateFormat (used in seller / order UI)
  await initializeDateFormatting('fr_FR');

  //* mapbox public token from --dart-define=MAPBOX_PUBLIC_TOKEN=...
  if (_mapboxPublicToken.isNotEmpty) {
    MapboxOptions.setAccessToken(_mapboxPublicToken);
  }

  Get.put(ThemeController());

  //* await native splash
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const App());
}
