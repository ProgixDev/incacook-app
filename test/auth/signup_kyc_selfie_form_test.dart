import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/models/auth/charter.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/models/requests/accept_charter_request.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/data/repositories/buyers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/charters_repository.dart';
import 'package:incacook/features/authentication/data/repositories/drivers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/kyc_repository.dart';
import 'package:incacook/features/authentication/data/repositories/sellers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_kyc_selfie_form.dart';

/// A real [ApiClient] built with an in-memory [TokenStorage] and never
/// actually dispatched — none of the repositories below are exercised for
/// network calls other than [_FakeUsersRepository.acceptCharter], which is
/// overridden directly.
ApiClient _fakeApiClient() => ApiClient(dio: Dio(), tokenStorage: TokenStorage());

/// #55 — the KYC selfie consent gate must block the capture CTA until the
/// checkbox is ticked and "Continuer" is tapped.
void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<AuthRepository>(AuthRepository(api: _fakeApiClient()));
    Get.put<UsersRepository>(_FakeUsersRepository(api: _fakeApiClient()));
    Get.put<ChartersRepository>(ChartersRepository(api: _fakeApiClient()));
    Get.put<BuyersRepository>(BuyersRepository(api: _fakeApiClient()));
    Get.put<SellersRepository>(SellersRepository(api: _fakeApiClient()));
    Get.put<DriversRepository>(DriversRepository(api: _fakeApiClient()));
    Get.put<KycRepository>(KycRepository(api: _fakeApiClient()));
    Get.put<SignupFlowController>(SignupFlowController());
  });

  tearDown(Get.reset);

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SignupKycSelfieForm())),
    );
  }

  testWidgets('shows the consent step first, capture CTA hidden', (tester) async {
    await pump(tester);
    expect(find.text(AppTexts.kycConsentTitle), findsOneWidget);
    expect(find.text(AppTexts.signupKycSelfieCta), findsNothing);
  });

  testWidgets('"Continuer" stays disabled until the checkbox is ticked', (tester) async {
    await pump(tester);
    final continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, AppTexts.kycConsentContinueCta),
    );
    expect(continueButton.onPressed, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final enabledButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, AppTexts.kycConsentContinueCta),
    );
    expect(enabledButton.onPressed, isNotNull);
  });

  testWidgets('tapping Continuer after consent reveals the capture CTA', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, AppTexts.kycConsentContinueCta));
    await tester.pump();

    expect(find.text(AppTexts.kycConsentTitle), findsNothing);
    expect(find.text(AppTexts.signupKycSelfieCta), findsOneWidget);
  });
}

/// Real [UsersRepository] except `acceptCharter`, which is short-circuited
/// so the consent-recording call never touches the network in tests.
class _FakeUsersRepository extends UsersRepository {
  _FakeUsersRepository({required super.api});

  @override
  Future<CharterAcceptance> acceptCharter(AcceptCharterRequest req) async {
    return CharterAcceptance(
      charter: req.charter,
      version: req.version,
      acceptedAt: DateTime.now().toIso8601String(),
    );
  }
}
