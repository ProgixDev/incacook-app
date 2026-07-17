import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/models/signup_step.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/buyer/buyer_address_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/buyer/buyer_dietary_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/buyer/buyer_done_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/driver/driver_charter_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/driver/driver_dob_address_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/driver/driver_documents_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/driver/driver_kyc_id_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/driver/driver_kyc_selfie_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/driver/driver_vehicle_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/driver/driver_zone_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/role_selection/role_selection_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/seller/seller_business_info_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/seller/seller_charter_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/seller/seller_cuisine_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/seller/seller_dob_address_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/seller/seller_kyc_id_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/seller/seller_kyc_selfie_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/seller/seller_profile_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/shared/payout_setup_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/universal/basic_info_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/universal/biometric_setup_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/universal/complete_name_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/universal/legal_acceptance_page.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/universal/phone_verification_page.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_bottom_bar.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_timeline.dart';

/// Container for the entire IncaCook signup flow. Owns the [PageView] and
/// pins the timeline to the top, the back chevron + counter, and the
/// sticky bottom action bar.
class SignupShellScreen extends GetView<SignupFlowController> {
  const SignupShellScreen({super.key});

  static Widget _pageFor(SignupStep step) {
    switch (step) {
      case SignupStep.basicInfo:
        return const BasicInfoPage();
      case SignupStep.phoneVerification:
        return const PhoneVerificationPage();
      case SignupStep.biometricSetup:
        return const BiometricSetupPage();
      case SignupStep.legalAcceptance:
        return const LegalAcceptancePage();
      case SignupStep.completeName:
        return const CompleteNamePage();
      case SignupStep.roleSelection:
        return const RoleSelectionPage();
      case SignupStep.buyerAddress:
        return const BuyerAddressPage();
      case SignupStep.buyerDietary:
        return const BuyerDietaryPage();
      case SignupStep.buyerDone:
        return const BuyerDonePage();
      case SignupStep.sellerProfile:
        return const SellerProfilePage();
      case SignupStep.sellerDobAddress:
        return const SellerDobAddressPage();
      case SignupStep.sellerBusinessInfo:
        return const SellerBusinessInfoPage();
      case SignupStep.sellerCuisine:
        return const SellerCuisinePage();
      case SignupStep.sellerKycId:
        return const SellerKycIdPage();
      case SignupStep.sellerKycSelfie:
        return const SellerKycSelfiePage();
      case SignupStep.sellerCharter:
        return const SellerCharterPage();
      case SignupStep.driverDobAddress:
        return const DriverDobAddressPage();
      case SignupStep.driverVehicle:
        return const DriverVehiclePage();
      case SignupStep.driverKycId:
        return const DriverKycIdPage();
      case SignupStep.driverKycSelfie:
        return const DriverKycSelfiePage();
      case SignupStep.driverDocuments:
        return const DriverDocumentsPage();
      case SignupStep.driverZone:
        return const DriverZonePage();
      case SignupStep.driverCharter:
        return const DriverCharterPage();
      case SignupStep.payoutSetup:
        return const PayoutSetupPage();
    }
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppTexts.signupExitDialogTitle),
        content: const Text(AppTexts.signupExitDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppTexts.signupExitCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text(AppTexts.signupExitConfirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onBack(BuildContext context) async {
    // After OTP verification the wizard is forward-only — guard both
    // the appbar tap and the system back gesture here.
    if (!controller.canGoBack) return;
    if (controller.isFirstPage) {
      if (await _confirmExit(context)) Get.back<void>();
    } else {
      controller.previousPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onBack(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        // Reactive: the back arrow disappears the moment phone/email
        // OTP verification flips [SignupFlowController.canGoBack].
        // PreferredSize re-wraps the Obx as a PreferredSizeWidget so it
        // satisfies Scaffold.appBar's contract; the inner CustomAppBar
        // already reports the same height.
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(DeviceUtils.getAppBarHeight()),
          child: Obx(
            () => CustomAppBar(
              showBackArrow: controller.canGoBack,
              leadingOnPressed: () => _onBack(context),
              actions: const [_StepCounterBadge()],
            ),
          ),
        ),
        // The bottom bar is a real layout footer (not a floating overlay), so
        // page content is physically constrained to the space *above* it and
        // can never hide behind it. With resizeToAvoidBottomInset the whole
        // column shrinks above the keyboard, docking the bar just above it so
        // "Continuer" stays visible while typing.
        body: Column(
          children: [
            const SignupTimeline(),
            const Gap(AppSizes.sm),
            Expanded(
              child: Obx(() {
                final steps = controller.steps;
                return PageView.builder(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: controller.onPageChanged,
                  itemCount: steps.length,
                  itemBuilder: (_, i) => _pageFor(steps[i]),
                );
              }),
            ),
            const SignupBottomBar(),
          ],
        ),
      ),
    );
  }
}

/// Frosted circle in the appbar action slot showing "current / total".
/// Mirrors the back-arrow's circular frosted treatment so they balance
/// visually at either end of the appbar.
class _StepCounterBadge extends GetView<SignupFlowController> {
  const _StepCounterBadge();

  @override
  Widget build(BuildContext context) {
    return FrostedSurface(
      shape: BoxShape.circle,
      child: SizedBox(
        width: AppSizes.lg * 1.8,
        height: AppSizes.lg * 1.8,
        child: Center(
          child: Obx(
            () => Text(
              // Guard against empty steps list during initialization.
              controller.totalPages == 0
                  ? '—'
                  : '${controller.currentPage.value + 1}/${controller.totalPages}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
