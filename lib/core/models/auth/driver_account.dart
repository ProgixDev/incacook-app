import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/features/authentication/data/models/driver_vehicle_type.dart';

part 'driver_account.freezed.dart';
part 'driver_account.g.dart';

/// The wizard-owned slice of a driver's account. Nested inside [User]
/// when `role == DRIVER`.
///
/// Mirrors `PUT /v1/drivers/me/vehicle` (§3.17) and
/// `PUT /v1/drivers/me/zones` (§3.18). Fields are nullable / empty until
/// the wizard fires those endpoints.
@freezed
abstract class DriverAccount with _$DriverAccount {
  const factory DriverAccount({
    DriverVehicleType? vehicleType,
    String? dateOfBirth,
    @Default(<String>[]) List<String> zones,
    @Default(false) bool canDeliver,

    // Payout/identity gate fields (mirror DriverProfileResponseDto). Drive the
    // delivery-claim gate: a driver can only claim once KYC is APPROVED and
    // Stripe Connect payout onboarding is complete.
    @Default('PENDING') String kycStatus,
    @Default(false) bool stripeOnboardingCompleted,

    // Split Stripe Connect facts (DEC-4). Nullable so "old server didn't
    // send them" stays distinguishable from an explicit false — readiness
    // then falls back to [stripeOnboardingCompleted]. Derivation lives in
    // `payout_readiness.dart` ([DriverPayoutReadiness]).
    bool? detailsSubmitted,
    bool? chargesEnabled,
    bool? payoutsEnabled,

    // Server-side online flag (mirrors DriverProfile.isOnline). Read on
    // relaunch to restore the driver's online session — the local toggle
    // otherwise always boots to offline. See DeliveryDriverController.
    @Default(false) bool isOnline,
  }) = _DriverAccount;

  factory DriverAccount.fromJson(Map<String, dynamic> json) =>
      _$DriverAccountFromJson(json);
}
