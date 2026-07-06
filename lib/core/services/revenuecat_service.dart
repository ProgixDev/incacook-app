import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:incacook/core/config/revenuecat_config.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/utils/log.dart';

/// Outcome of a purchase / restore, distilled to what the backend sync needs.
/// Never carries tokens or receipts.
class SubscriptionOutcome {
  const SubscriptionOutcome({
    this.cancelled = false,
    this.entitlementId,
    this.productId,
    this.expiresAtMs,
    this.isTrial = false,
  });

  /// User dismissed the store sheet — silent at the UI layer.
  final bool cancelled;

  /// `seller_premium` | `seller_standard` | null (no active seller entitlement).
  final String? entitlementId;
  final String? productId;
  final int? expiresAtMs;
  final bool isTrial;

  bool get hasActiveEntitlement => entitlementId != null;
}

/// Thrown for a real purchase/restore failure (not a user cancellation).
class RevenueCatException implements Exception {
  const RevenueCatException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Why an offering couldn't be loaded — drives a precise paywall message.
enum OfferingFailure {
  /// No public SDK key in this build → SDK never configured.
  keyMissing,

  /// `getOfferings` threw (store / network / sandbox products not fetchable).
  storeError,

  /// SDK ok, but no offering matches the expected id (dashboard mismatch).
  offeringMissing,
}

/// Result of loading a category's offering. [offering] is non-null only when
/// the named offering was found (its packages may still be empty / mismatched,
/// which the paywall detects separately).
class OfferingResult {
  const OfferingResult({this.offering, this.failure});
  final Offering? offering;
  final OfferingFailure? failure;
}

/// Thin wrapper around RevenueCat (`purchases_flutter`) for the **seller
/// monthly subscription only**. Configured at startup with the public SDK key;
/// the seller logs in with their backend `User.id` as the RevenueCat
/// appUserID so the webhook can map events back to the seller.
class RevenueCatService extends GetxService {
  bool _configured = false;
  bool get isConfigured => _configured;

  /// Idempotent. Safe to call when no key is set (just stays inactive).
  ///
  /// TEMP TestFlight debug logs (no secrets — never logs the API key):
  /// `[RevenueCat] platform=… configured=<key present>` and
  /// `[RevenueCat] sdk configured success=<Purchases.configure ok>`.
  Future<void> init() async {
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'iOS'
        : defaultTargetPlatform == TargetPlatform.android
        ? 'Android'
        : 'other';
    final keyPresent = RevenueCatConfig.isConfigured;
    logInfo('[RevenueCat] platform=$platform configured=$keyPresent');

    if (!keyPresent) {
      logWarning('[RevenueCat] not configured (no public SDK key) — skipping');
      return;
    }
    try {
      await Purchases.configure(
        PurchasesConfiguration(RevenueCatConfig.apiKey),
      );
      _configured = true;
      logSuccess('[RevenueCat] sdk configured success=true');
    } catch (e) {
      // Never block app startup on the billing SDK.
      logError('[RevenueCat] configure failed: $e');
    }
  }

  /// Identifies the subscriber with the backend user id (= webhook app_user_id).
  Future<void> login(String appUserId) async {
    if (!_configured || appUserId.isEmpty) return;
    try {
      await Purchases.logIn(appUserId);
    } catch (e) {
      logError('[RevenueCat] logIn failed: $e');
    }
  }

  /// Loads the offering for [category] and reports a precise failure reason so
  /// the paywall can show an actionable message. Throws nothing.
  ///
  /// TEMP TestFlight debug logs (no secrets):
  ///   `[RevenueCat] getOfferings start`
  ///   `[RevenueCat] offeringId=…`
  ///   `[RevenueCat] getOfferings success=…`
  ///   `[RevenueCat] current offering exists=…`
  ///   `[RevenueCat] packages count=…`
  ///   `[Subscription] available packages=[…]`
  /// On error: `error code=…` / `error message=…` / `underlying=…`.
  Future<OfferingResult> loadOfferingForCategory(
    SellerCategory category,
  ) async {
    final offeringId = RevenueCatConfig.offeringIdForCategory(category);
    if (!_configured) {
      logWarning('[RevenueCat] getOfferings skipped reason=key-missing');
      return const OfferingResult(failure: OfferingFailure.keyMissing);
    }
    logInfo('[RevenueCat] getOfferings start offeringId=$offeringId');
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.all[offeringId];
      final exists = offering != null;
      final ids =
          offering?.availablePackages.map((p) => p.identifier).toList() ??
          const <String>[];
      logSuccess(
        '[RevenueCat] getOfferings success=true exists=$exists packages=$ids',
      );
      if (!exists) {
        // Log which offerings DID come back — pinpoints a dashboard id typo.
        logWarning(
          '[RevenueCat] offeringMissing: store returned ${offerings.all.keys.toList()}',
        );
        return const OfferingResult(failure: OfferingFailure.offeringMissing);
      }
      return OfferingResult(offering: offering);
    } on PlatformException catch (e) {
      logError(
        '[RevenueCat] getOfferings failed '
        'code=${PurchasesErrorHelper.getErrorCode(e)} '
        'message=${e.message ?? ''} '
        'underlying=${_safeUnderlying(e.details)}',
      );
      return const OfferingResult(failure: OfferingFailure.storeError);
    } catch (e) {
      logError('[RevenueCat] getOfferings failed: $e');
      return const OfferingResult(failure: OfferingFailure.storeError);
    }
  }

  /// Extracts a safe underlying-error string from a PlatformException's
  /// `details` (RevenueCat puts a readable code / store message here). Never
  /// contains the API key or tokens, but we only surface known string fields.
  static String _safeUnderlying(Object? details) {
    if (details is Map) {
      final v =
          details['underlyingErrorMessage'] ?? details['readableErrorCode'];
      if (v != null) return v.toString();
    } else if (details is String && details.isNotEmpty) {
      return details;
    }
    return 'n/a';
  }

  /// Purchases [package] and returns the resulting seller entitlement state.
  /// Maps a user cancellation to `cancelled: true` (silent); any other store
  /// error throws [RevenueCatException].
  Future<SubscriptionOutcome> purchase(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _outcomeFrom(result.customerInfo);
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return const SubscriptionOutcome(cancelled: true);
      }
      // Never surface raw store/receipt internals — generic French message.
      throw const RevenueCatException(
        'Abonnement impossible. Veuillez réessayer.',
      );
    }
  }

  /// Restores prior purchases and returns the resulting seller entitlement
  /// state. Throws [RevenueCatException] on a store error.
  Future<SubscriptionOutcome> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      return _outcomeFrom(info);
    } on PlatformException {
      throw const RevenueCatException(
        'Restauration impossible. Veuillez réessayer.',
      );
    }
  }

  /// Reads the current subscriber's active seller entitlement from RevenueCat
  /// WITHOUT making a purchase — used to reconcile a device that already owns
  /// the subscription against a backend showing NONE (e.g. a post-purchase sync
  /// that failed). Returns an empty outcome when unconfigured or on error.
  Future<SubscriptionOutcome> currentOutcome() async {
    if (!_configured) return const SubscriptionOutcome();
    try {
      final info = await Purchases.getCustomerInfo();
      return _outcomeFrom(info);
    } on PlatformException catch (e) {
      logWarning('[RevenueCat] getCustomerInfo failed: ${e.message ?? e}');
      return const SubscriptionOutcome();
    }
  }

  /// Store URL for managing the current subscription. RevenueCat returns the
  /// correct App Store / Play Store destination when an active subscription
  /// exists on the current device account.
  Future<String?> subscriptionManagementUrl() async {
    if (!_configured) return null;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.managementURL;
    } on PlatformException catch (e) {
      logWarning('[RevenueCat] managementURL failed: ${e.message ?? e}');
      return null;
    }
  }

  /// Reads the active seller entitlement (premium wins) out of a [CustomerInfo].
  SubscriptionOutcome _outcomeFrom(CustomerInfo info) {
    final active = info.entitlements.active;
    final ent =
        active[RevenueCatConfig.entitlementPremium] ??
        active[RevenueCatConfig.entitlementStandard];
    if (ent == null) return const SubscriptionOutcome();
    return SubscriptionOutcome(
      entitlementId: ent.identifier,
      productId: ent.productIdentifier,
      expiresAtMs: DateTime.tryParse(
        ent.expirationDate ?? '',
      )?.toUtc().millisecondsSinceEpoch,
      isTrial: ent.periodType == PeriodType.trial,
    );
  }
}
