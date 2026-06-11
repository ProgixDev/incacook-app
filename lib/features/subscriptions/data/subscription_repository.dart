import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';

/// Seller platform subscription ($4/mo) state, mirrors the backend
/// `GET /v1/sellers/me/subscription` response.
class SubscriptionStatusInfo {
  const SubscriptionStatusInfo({
    required this.status,
    required this.active,
    this.currentPeriodEnd,
  });

  /// Raw status: NONE / ACTIVE / TRIALING / PAST_DUE / CANCELED / ...
  final String status;

  /// Derived gate the app uses to unlock seller features.
  final bool active;

  /// Renewal date (end of current paid period), or null.
  final DateTime? currentPeriodEnd;

  factory SubscriptionStatusInfo.fromJson(Map<String, dynamic> json) {
    final raw = json['currentPeriodEnd'] as String?;
    return SubscriptionStatusInfo(
      status: (json['status'] as String?) ?? 'NONE',
      active: (json['active'] as bool?) ?? false,
      currentPeriodEnd: raw != null ? DateTime.tryParse(raw) : null,
    );
  }
}

/// Result of starting an in-app subscription. `clientSecret` is the first
/// invoice's PaymentIntent secret to confirm the card with `flutter_stripe`
/// (null when no payment is required).
class SubscriptionIntent {
  const SubscriptionIntent({
    required this.clientSecret,
    required this.subscriptionId,
    required this.status,
  });

  final String? clientSecret;
  final String subscriptionId;
  final String status;

  factory SubscriptionIntent.fromJson(Map<String, dynamic> json) {
    return SubscriptionIntent(
      clientSecret: json['clientSecret'] as String?,
      subscriptionId: (json['subscriptionId'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
    );
  }
}

/// Talks to the seller subscription endpoints. `createSubscription` returns
/// a PaymentIntent secret the app confirms in-app (same as buyer checkout);
/// the Portal returns a hosted URL (manage / cancel / invoices); status
/// drives the paywall + dashboard. The backend (webhooks) is the source of
/// truth.
class SubscriptionRepository {
  const SubscriptionRepository();

  static const String _base = '${ApiConstants.apiPrefix}/sellers/me/subscription';

  /// Reads the seller's current subscription state.
  Future<SubscriptionStatusInfo> getStatus() async {
    final res = await ApiClient.instance.get<SubscriptionStatusInfo>(
      _base,
      decoder: (json) =>
          SubscriptionStatusInfo.fromJson(json! as Map<String, dynamic>),
    );
    return res.data;
  }

  /// Creates (or reuses) the $4/mo subscription and returns the
  /// PaymentIntent client secret to confirm with the card in-app.
  Future<SubscriptionIntent> createSubscription() async {
    final res = await ApiClient.instance.post<SubscriptionIntent>(
      _base,
      decoder: (json) =>
          SubscriptionIntent.fromJson(json! as Map<String, dynamic>),
    );
    return res.data;
  }

  /// Opens the Stripe Billing Portal (update card / cancel / invoices).
  Future<String> createPortalUrl() async {
    final res = await ApiClient.instance.post<String>(
      '$_base/portal',
      decoder: (json) => (json! as Map<String, dynamic>)['url'] as String,
    );
    return res.data;
  }
}
