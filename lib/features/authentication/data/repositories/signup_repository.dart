import 'package:get/get.dart';

/// Stub repository for signup-flow side effects that don't yet have a
/// documented backend endpoint: phone OTP, document uploads, address
/// search.
///
/// Auth + profile creation moved to [AuthRepository] / [UsersRepository].
/// As role-specific finalizer endpoints land (KYC, business info,
/// vehicle, etc.), pull each one out into its own typed repository and
/// shrink this file further.
class SignupRepository extends GetxService {
  /// Sends an OTP to the given phone. Stubbed: always succeeds, expected
  /// code is `123456`.
  Future<void> sendOtp(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  /// Verifies the OTP. Stubbed: returns true for `123456`, false otherwise.
  Future<bool> verifyOtp({required String phone, required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return code == '123456';
  }

  /// Stub geocoding lookup — returns a deterministic fake list of suggestions.
  Future<List<String>> searchAddresses(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (query.trim().isEmpty) return const [];
    return [
      '$query, 75001 Paris',
      '$query, 69001 Lyon',
      '$query, 13001 Marseille',
    ];
  }

}
