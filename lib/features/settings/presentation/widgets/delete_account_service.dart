import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/services/revenuecat_service.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/authentication/services/sign_out_service.dart';

/// Drives the "Supprimer mon compte" flow from Settings (#51):
///
/// 1. If the caller is a seller with an active subscription, warn that
///    deleting the IncaCook account does NOT cancel the store subscription
///    (Apple/Google don't allow server-side cancellation) — offer to open
///    subscription management first, or continue anyway.
/// 2. Two-step destructive confirmation.
/// 3. `DELETE /v1/users/me`. A `409` (ACTIVE_ORDER / NONZERO_WALLET /
///    OUTSTANDING_DEBT) surfaces a readable French reason and leaves the
///    user signed in. On success, wipes local state and returns to Welcome.
class DeleteAccountService {
  DeleteAccountService._();

  static Future<void> start(BuildContext context) async {
    final seller = UserController.instance.user.value?.sellerAccount;
    if (seller?.subscriptionActive ?? false) {
      final proceed = await _showSubscriptionWarning(context);
      if (proceed != true) return;
      if (!context.mounted) return;
    }

    final step1 = await _confirm(
      context,
      title: AppTexts.deleteAccountConfirmTitle,
      body: AppTexts.deleteAccountConfirmBody,
      cancelLabel: AppTexts.deleteAccountConfirmCancel,
      actionLabel: AppTexts.deleteAccountConfirmContinue,
    );
    if (step1 != true || !context.mounted) return;

    final step2 = await _confirm(
      context,
      title: AppTexts.deleteAccountFinalTitle,
      body: AppTexts.deleteAccountFinalBody,
      cancelLabel: AppTexts.deleteAccountFinalCancel,
      actionLabel: AppTexts.deleteAccountFinalAction,
      destructive: true,
    );
    if (step2 != true) return;

    await _delete();
  }

  static Future<bool?> _showSubscriptionWarning(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppTexts.deleteAccountSubscriptionWarningTitle),
        content: const Text(AppTexts.deleteAccountSubscriptionWarningBody),
        actions: [
          TextButton(
            onPressed: () async {
              final rc = Get.isRegistered<RevenueCatService>()
                  ? Get.find<RevenueCatService>()
                  : null;
              final url = await rc?.subscriptionManagementUrl();
              final uri = Uri.tryParse(url ?? '');
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              if (dialogContext.mounted) Navigator.of(dialogContext).pop(false);
            },
            child: const Text(
              AppTexts.deleteAccountSubscriptionWarningManageCta,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              AppTexts.deleteAccountSubscriptionWarningContinueCta,
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String cancelLabel,
    required String actionLabel,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: destructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(dialogContext).colorScheme.error,
                  )
                : null,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  static Future<void> _delete() async {
    try {
      await UsersRepository.instance.deleteAccount();
    } on ApiFailure catch (e) {
      CustomLoaders.errorSnackBar(
        title: AppTexts.settingsDeleteAccount,
        message: _messageFor(e.code),
      );
      return;
    } catch (_) {
      CustomLoaders.errorSnackBar(
        title: AppTexts.settingsDeleteAccount,
        message: AppTexts.deleteAccountGenericError,
      );
      return;
    }
    // Best-effort local wipe beyond what SignOutService already clears
    // (secure token storage) — GetStorage holds prefs (e.g. "remember me"
    // email) that shouldn't survive a deleted account.
    try {
      await GetStorage().erase();
    } catch (_) {
      // Non-fatal — proceed to sign out regardless.
    }
    CustomLoaders.successSnackBar(
      title: AppTexts.settingsDeleteAccount,
      message: AppTexts.deleteAccountSuccess,
    );
    // The account no longer exists server-side, so /v1/auth/signout will
    // likely 401 — SignOutService swallows that and still clears local
    // state + navigates to Welcome, which is exactly what we want here.
    await SignOutService.signOut();
  }

  static String _messageFor(String code) {
    switch (code) {
      case 'ACTIVE_ORDER':
        return AppTexts.deleteAccountBlockedActiveOrder;
      case 'NONZERO_WALLET':
        return AppTexts.deleteAccountBlockedNonzeroWallet;
      case 'OUTSTANDING_DEBT':
        return AppTexts.deleteAccountBlockedOutstandingDebt;
      default:
        return AppTexts.deleteAccountGenericError;
    }
  }
}
