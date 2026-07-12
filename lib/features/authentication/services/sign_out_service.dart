import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/services/native_google_auth_service.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/services/notifications/push_notification_service.dart';
import 'package:incacook/core/services/supabase_oauth_service.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/presentation/screens/welcome.dart';

/// Stateless helper that orchestrates the user-facing sign-out flow:
/// confirm → revoke session server-side → drop tokens → navigate.
///
/// The actual token clearing is a side effect of [AuthRepository.signout]
/// (in its `finally`), so even if the server call fails the device is
/// signed out locally — that's the right call for a "log me out" intent.
class SignOutService {
  SignOutService._();

  /// Shows a confirmation dialog, then signs out if the user confirms.
  /// Safe to call from any [BuildContext] that has a [Navigator].
  static Future<void> promptAndSignOut(BuildContext context) async {
    final confirmed = await _SignOutConfirmDialog.show(context);
    if (confirmed != true) return;
    await signOut();
  }

  /// Performs the sign-out without prompting. Useful for places that
  /// already confirmed (e.g. a 403 forced-logout flow if one ever lands).
  static Future<void> signOut() async {
    // LocationService is app-permanent. Stop it explicitly before auth state and
    // route-scoped driver controllers are torn down so logout can never leave a
    // heartbeat or background delivery stream running for the signed-out user.
    if (Get.isRegistered<LocationService>()) {
      try {
        await LocationService.instance.applyMode(LocationMode.off);
      } catch (_) {
        // Best-effort cleanup must never trap the user in the signed-in UI.
      }
    }
    // Unregister this device's FCM token FIRST — the DELETE is authenticated,
    // and AuthRepository.signout() clears the bearer in its finally. Doing it
    // here stops the logged-out device from receiving this user's pushes.
    // Best-effort: never block leaving the protected screens.
    if (Get.isRegistered<PushNotificationService>()) {
      try {
        await PushNotificationService.instance.unregisterCurrentToken();
      } catch (_) {
        // ignore
      }
    }
    try {
      await AuthRepository.instance.signout();
    } catch (_) {
      // Swallow — token clearing already happened in the repo's finally.
      // We still want to navigate the user out.
    }
    // Clear Supabase's locally-cached social session. Local scope only — the
    // live bearer was already revoked above via /v1/auth/signout. No-op for
    // email/password users. Best-effort — never block leaving the screen.
    if (Get.isRegistered<SupabaseOAuthService>()) {
      try {
        await Get.find<SupabaseOAuthService>().signOut();
      } catch (_) {
        // ignore
      }
    }
    if (Get.isRegistered<NativeGoogleAuthService>()) {
      try {
        await Get.find<NativeGoogleAuthService>().signOut();
      } catch (_) {
        // ignore
      }
    }
    // Drop the cached user before navigating so any settings/profile
    // widget still in the disposing tree flips to `null` instead of
    // briefly showing stale info.
    if (Get.isRegistered<UserController>()) {
      UserController.instance.clear();
    }
    // offAll wipes the navigator stack so the protected screens behind
    // the user can't be revisited via the back gesture.
    await Get.offAll<void>(() => const WelcomeScreen());
  }
}

/// Confirmation dialog with a frosted backdrop (matches
/// `showBlurredModalBottomSheet`'s look) and a pair of elevated buttons.
///
/// Sits behind a transparent barrier so the [BackdropFilter] can do the
/// dimming — gives a soft, modern look instead of the default opaque
/// black overlay.
class _SignOutConfirmDialog extends StatelessWidget {
  const _SignOutConfirmDialog();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      // Transparent so the BackdropFilter inside the builder is the
      // only thing painting over the underlying screen.
      barrierColor: Colors.transparent,
      // Default is true, which wraps the builder in a SafeArea and
      // clips the BackdropFilter at the status bar / home indicator.
      // We position the card with our own Center + insets below, so
      // edge-to-edge blur is what we actually want.
      useSafeArea: false,
      builder: (_) => const _SignOutConfirmDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final barrier = context.appColors.barrierOverlay;
    return Stack(
      children: [
        // Full-bleed blur + theme-aware translucent overlay. Tapping
        // outside the dialog dismisses it.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(false),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: ColoredBox(color: barrier),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Material(
              color: scheme.surface,
              elevation: 0,
              borderRadius: BorderRadius.circular(40),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.settingsLogoutConfirmTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(AppSizes.sm + 2),
                    Text(
                      AppTexts.settingsLogoutConfirmBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const Gap(AppSizes.lg),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.surfaceContainerHigh,
                              foregroundColor: scheme.onSurface,
                              elevation: 0,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              AppTexts.settingsLogoutConfirmCancel,
                            ),
                          ),
                        ),
                        const Gap(AppSizes.sm + 2),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.error,
                              foregroundColor: scheme.onError,
                              elevation: 0,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              AppTexts.settingsLogoutConfirmAction,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
