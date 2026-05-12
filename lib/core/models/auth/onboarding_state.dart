import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/models/auth/kyc_document.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';

part 'onboarding_state.freezed.dart';
part 'onboarding_state.g.dart';

/// Per-step status returned by §4.1.
enum OnboardingStatus {
  @JsonValue('complete')
  complete,
  @JsonValue('incomplete')
  incomplete,
  @JsonValue('skipped')
  skipped,
  @JsonValue('pending_review')
  pendingReview,
}

/// Response of `GET /v1/users/me/onboarding` (§4.1).
///
/// The keystone of cold-start resume — fetched on app launch when a
/// session exists, and after every role-specific PUT/POST to learn what
/// to render next. `steps` is intentionally a `Map<String, ...>` rather
/// than an enum-keyed map: the doc's step keys (`profile`, `business`,
/// `cuisines`, `kyc_id`, …) are role-specific and may evolve, so the
/// client looks them up by string and falls back to UI order for any
/// keys it doesn't recognize.
@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    required UserRole role,

    /// First incomplete step in canonical role order, or null when
    /// every step is `complete` or `skipped`. Wizard's cold-start resume
    /// maps this to a [SignupStep] to jump the PageView.
    String? next,

    @Default(<String, OnboardingStatus>{}) Map<String, OnboardingStatus> steps,

    /// KYC review state aggregated across the user's KycDocument rows.
    /// Null for buyers (no KYC required).
    KycReviewState? kycReviewState,

    /// Server-derived gate flags. Only one of the two is present per role.
    bool? canList,
    bool? canDeliver,
  }) = _OnboardingState;

  factory OnboardingState.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStateFromJson(json);
}
