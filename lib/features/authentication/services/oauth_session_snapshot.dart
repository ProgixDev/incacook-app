/// Token-only view of a Supabase OAuth session. Keeping this small makes
/// cold-return recovery deterministic and testable without a platform client.
class OAuthSessionSnapshot {
  const OAuthSessionSnapshot({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresAt;
}
