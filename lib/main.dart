import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:incacook/app.dart';
import 'package:incacook/core/controllers/theme_controller.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/data/repositories/buyers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/charters_repository.dart';
import 'package:incacook/features/authentication/data/repositories/drivers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/kyc_repository.dart';
import 'package:incacook/features/authentication/data/repositories/sellers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/uploads_repository.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const _mapboxPublicToken = String.fromEnvironment('MAPBOX_PUBLIC_TOKEN');

void main() async {
  //* add widgets bindings
  WidgetsFlutterBinding.ensureInitialized();

  //* init local storage
  await GetStorage.init();

  //* init French locale data for intl DateFormat (used in seller / order UI)
  await initializeDateFormatting('fr_FR');

  //* mapbox public token from --dart-define=MAPBOX_PUBLIC_TOKEN=...
  if (_mapboxPublicToken.isNotEmpty) {
    MapboxOptions.setAccessToken(_mapboxPublicToken);
  }

  Get.put(ThemeController());

  //* network layer — register before any repository that depends on it.
  //  Order matters: TokenStorage feeds AuthInterceptor inside ApiClient.
  Get.put<TokenStorage>(TokenStorage(), permanent: true);
  Get.put<ApiClient>(ApiClient(), permanent: true);
  Get.put<AuthRepository>(AuthRepository(), permanent: true);
  Get.put<UsersRepository>(UsersRepository(), permanent: true);
  Get.put<ChartersRepository>(ChartersRepository(), permanent: true);
  Get.put<UploadsRepository>(UploadsRepository(), permanent: true);
  Get.put<KycRepository>(KycRepository(), permanent: true);
  Get.put<BuyersRepository>(BuyersRepository(), permanent: true);
  Get.put<SellersRepository>(SellersRepository(), permanent: true);
  Get.put<DriversRepository>(DriversRepository(), permanent: true);

  runApp(const App());
}
