import 'package:get/get.dart';

/// Stub repository for signup operations. All methods return mocked
/// responses with simulated network delays so the flow can be exercised
/// end-to-end without a backend.
///
/// Replace each method with a real Dio call when the API is available.
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

  /// Stub document upload. Returns a fake remote path.
  Future<String> uploadDocument(String localPath) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return 'https://cdn.culinea.local/uploads/${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Final signup submission. Stubbed: always succeeds after a short delay.
  Future<void> submitSignup(Map<String, dynamic> payload) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
  }
}
