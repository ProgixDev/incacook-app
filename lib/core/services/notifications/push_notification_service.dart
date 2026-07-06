import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/services/notifications/device_tokens_repository.dart';
import 'package:incacook/features/orders/presentation/screens/order_tracking.dart';
import 'package:incacook/core/utils/log.dart';
import 'package:incacook/firebase_options.dart';

/// Background / terminated-state FCM handler. MUST be a top-level (or static)
/// function and is registered from `main.dart` via
/// `FirebaseMessaging.onBackgroundMessage`. Runs in its own isolate, so it
/// re-initialises Firebase before touching the message. v1 only logs — system
/// tray display of `notification` messages is automatic on Android.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logInfo(
    '[FCM][bg] message=${message.messageId} '
    'title=${message.notification?.title} data=${message.data}',
  );
}

/// Owns the device-side push lifecycle: permission, token retrieval, backend
/// registration (only while authenticated), token refresh, and foreground /
/// open handlers. Registered as a permanent GetX service in `main.dart`.
///
/// Token registration is gated on auth state by observing
/// [UserController.user] — the token is sent the moment a user is present
/// (login / signup / cold-start rehydrate) and re-sent on refresh.
class PushNotificationService extends GetxService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    DeviceTokensRepository? repository,
    UserController? userController,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _repo = repository ?? Get.find<DeviceTokensRepository>(),
       _userController = userController ?? Get.find<UserController>();

  static PushNotificationService get instance => Get.find();

  final FirebaseMessaging _messaging;
  final DeviceTokensRepository _repo;
  final UserController _userController;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Android channel used to surface foreground messages (FCM doesn't show a
  /// system notification while the app is in the foreground).
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'incacook_default',
    'IncaCook Notifications',
    description: 'General IncaCook notifications',
    importance: Importance.high,
  );

  /// Platform tag sent to the backend. Keep this aligned with
  /// RegisterDeviceTokenDto on the API.
  static String get _platform => Platform.isIOS ? 'IOS' : 'ANDROID';

  String? _currentToken;
  bool _registeredOnce = false;

  /// Wires everything up. Safe to call once at startup — every step is
  /// guarded so a misconfigured Firebase project never blocks app boot.
  Future<void> init() async {
    try {
      await _messaging.requestPermission();
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      await _initLocalNotifications();

      _currentToken = await _loadInitialToken();
      // Never log the token value. Presence only.
      logWarning(
        '[FCM] token received: ${_currentToken != null && _currentToken!.isNotEmpty}',
      );

      // Register now if a session already exists (cold-start rehydrate),
      // then on every transition into an authenticated state.
      if (_userController.isSignedIn) {
        await _registerCurrentToken();
      }
      ever<dynamic>(_userController.user, (u) {
        if (u != null) _registerCurrentToken();
      });

      _messaging.onTokenRefresh.listen((token) {
        logInfo('[FCM] token refreshed');
        _currentToken = token;
        _registeredOnce = false;
        if (_userController.isSignedIn) _registerCurrentToken();
      });

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        logInfo('[FCM] opened from notification: data=${message.data}');
        // App was backgrounded → the route stack is live, safe to navigate.
        _routeForNotification(message);
      });

      // App launched from a terminated state by tapping a notification.
      // We only LOG here — navigating during cold-start init races the first
      // route being mounted; deep-link-from-terminated is a later task.
      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        logError('[FCM] launched from notification: data=${initial.data}');
      }
    } catch (e) {
      // Never let push setup crash the app (e.g. missing Firebase config).
      logError('[FCM] init failed: $e');
    }
  }

  /// Gets the first FCM token without aborting notification setup when iOS
  /// temporarily refuses token creation (`Too many server requests`) or APNs
  /// has not attached a token yet. Token refresh still registers later.
  Future<String?> _loadInitialToken() async {
    if (Platform.isIOS) {
      final apnsToken = await _waitForApnsToken();
      if (apnsToken == null || apnsToken.isEmpty) {
        logWarning('[FCM] APNs token unavailable; waiting for token refresh');
        return null;
      }
    }

    try {
      return await _messaging.getToken();
    } catch (e) {
      logWarning('[FCM] initial token unavailable: $e');
      return null;
    }
  }

  Future<String?> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 8; attempt++) {
      try {
        final token = await _messaging.getAPNSToken();
        if (token != null && token.isNotEmpty) return token;
      } catch (e) {
        logWarning('[FCM] APNs token read failed: $e');
        return null;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    return null;
  }

  /// Sends the current token to the backend. No-op when there's no token or
  /// it was already registered for this token value.
  Future<void> _registerCurrentToken() async {
    final token = _currentToken;
    if (token == null || token.isEmpty || _registeredOnce) return;
    try {
      await _repo.register(token: token, platform: _platform);
      _registeredOnce = true;
      logSuccess('[FCM] token registered with backend');
    } catch (e) {
      logError('[FCM] token registration failed: $e');
    }
  }

  /// Best-effort unregister. Call BEFORE clearing the auth token on logout
  /// (the DELETE is authenticated). Not yet wired into sign-out.
  Future<void> unregisterCurrentToken() async {
    final token = _currentToken;
    if (token == null || token.isEmpty) return;
    try {
      await _repo.unregister(token: token);
      _registeredOnce = false;
    } catch (e) {
      logError('[FCM] token unregister failed: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(settings: initSettings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  /// Safe tap-routing for business notifications. `order_*` and `delivery_*`
  /// events all carry an `orderId` and map cleanly to the order-tracking
  /// screen (which fetches the real order/delivery snapshot and degrades
  /// gracefully). Any other type is a no-op (logging only). Never throws.
  void _routeForNotification(RemoteMessage message) {
    try {
      final type = (message.data['type'] as String?) ?? '';
      final orderId = (message.data['orderId'] as String?) ?? '';
      if (orderId.isEmpty) return;
      if (type.startsWith('order_') || type.startsWith('delivery_')) {
        Get.to<void>(() => OrderTrackingScreen(orderId: orderId));
      }
    } catch (e) {
      logError('[FCM] route handling failed: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    logInfo(
      '[FCM] foreground: title=${notification?.title} '
      'body=${notification?.body} data=${message.data}',
    );
    if (notification == null) return;
    // Surface it ourselves — FCM won't draw a tray notification in foreground.
    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
