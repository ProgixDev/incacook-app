import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:incacook/core/services/supabase_oauth_service.dart';
import 'package:incacook/core/utils/log.dart';

/// Result of a native Apple sign-in: the Supabase [session] plus the name
/// Apple returned — which it only ever sends on the user's **first**
/// authorization for this app. Callers must persist [firstName]/[lastName]
/// immediately; they're unrecoverable on any later sign-in.
class AppleSignInResult {
  const AppleSignInResult({required this.session, this.firstName, this.lastName});

  final Session session;
  final String? firstName;
  final String? lastName;
}

/// Native "Sign in with Apple" followed by a Supabase ID-token session
/// exchange — mirrors [NativeGoogleAuthService]'s shape so
/// `WelcomeController` can treat it identically (persistOAuthSession +
/// the provider-agnostic `POST /v1/auth/oauth/sync`). No new backend
/// endpoint needed.
class NativeAppleAuthService extends GetxService {
  Future<AppleSignInResult?> signIn() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256(rawNonce);

    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        logInfo('[Auth][Apple] native sign-in cancelled');
        return null;
      }
      logError('[Auth][Apple] native sign-in failed: ${e.code}');
      throw OAuthSignInException(
        e.message.isNotEmpty ? e.message : 'Connexion Apple impossible.',
      );
    }

    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw const OAuthSignInException('Jeton Apple manquant.');
    }

    final response = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    final session = response.session;
    if (session == null) {
      throw const OAuthSignInException('Session Apple introuvable.');
    }

    return AppleSignInResult(
      session: session,
      firstName: credential.givenName,
      lastName: credential.familyName,
    );
  }

  /// Cryptographically random nonce, hex-encoded (Apple + Supabase's
  /// documented pattern for id-token replay protection).
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256(String input) => sha256.convert(utf8.encode(input)).toString();

  Future<void> signOut() async {
    // Apple has no client-side session to revoke beyond Supabase's, which
    // SignOutService already clears. No-op kept for interface symmetry
    // with NativeGoogleAuthService.signOut().
  }
}
