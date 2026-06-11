import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:incacook/app.dart';
import 'package:incacook/core/config/mapbox_config.dart';
import 'package:incacook/core/config/stripe_config.dart';
import 'package:incacook/core/services/notifications/device_tokens_repository.dart';
import 'package:incacook/core/services/notifications/push_notification_service.dart';
import 'package:incacook/core/controllers/theme_controller.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/core/services/google_auth_service.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/data/repositories/buyers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/charters_repository.dart';
import 'package:incacook/features/authentication/data/repositories/drivers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/kyc_repository.dart';
import 'package:incacook/features/authentication/data/repositories/sellers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/uploads_repository.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/authentication/services/post_auth_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() async {
  //* add widgets bindings
  WidgetsFlutterBinding.ensureInitialized();

  //* init local storage
  await GetStorage.init();

  //* Firebase / FCM. Guarded so a missing/misconfigured google-services.json
  //  can never brick startup — push notifications just stay disabled.
  //  Android reads the config from google-services.json (no options needed).
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('[FCM] Firebase init failed: $e');
  }

  //* init French locale data for intl DateFormat (used in seller / order UI)
  await initializeDateFormatting('fr_FR');

  //* mapbox public token from --dart-define=MAPBOX_PUBLIC_TOKEN=...
  if (MapboxConfig.isConfigured) {
    MapboxOptions.setAccessToken(MapboxConfig.publicToken);
  } else {
    debugPrint(MapboxConfig.missingTokenMessage);
  }

  //* Stripe — only initialise when a publishable key is configured. Until
  //* then checkout falls back to the dev bypass, so the app still boots
  //* and orders still complete without a real card charge.
  if (StripeConfig.isConfigured) {
    Stripe.publishableKey = StripeConfig.publishableKey;
    await Stripe.instance.applySettings();
  }

  Get.put(ThemeController());

  //* network layer — register before any repository that depends on it.
  //  Order matters: TokenStorage feeds AuthInterceptor inside ApiClient.
  Get.put<TokenStorage>(TokenStorage(), permanent: true);
  Get.put<ApiClient>(ApiClient(), permanent: true);
  Get.put<AuthRepository>(AuthRepository(), permanent: true);
  Get.put<UsersRepository>(UsersRepository(), permanent: true);
  Get.put<UserController>(UserController(), permanent: true);
  Get.put<ChartersRepository>(ChartersRepository(), permanent: true);
  Get.put<UploadsRepository>(UploadsRepository(), permanent: true);
  Get.put<KycRepository>(KycRepository(), permanent: true);
  Get.put<BuyersRepository>(BuyersRepository(), permanent: true);
  Get.put<SellersRepository>(SellersRepository(), permanent: true);
  Get.put<DriversRepository>(DriversRepository(), permanent: true);
  Get.put<GoogleAuthService>(GoogleAuthService(), permanent: true);
  Get.put<PostAuthRouter>(PostAuthRouter(), permanent: true);

  //* push notifications — depends on ApiClient + UserController above.
  //  init() is fire-and-forget and fully guarded, so it never blocks boot.
  Get.put<DeviceTokensRepository>(DeviceTokensRepository(), permanent: true);
  Get.put<PushNotificationService>(PushNotificationService(), permanent: true);
  unawaited(PushNotificationService.instance.init());

  runApp(const App());
}
