/// Extracts the proof token shared by pickup and delivery handoff QR payloads.
/// Bare values are accepted only by the driver's explicit manual-entry path.
String? handoffTokenFromPayload(String raw, {bool acceptBare = false}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  final queryToken = uri?.queryParameters['token'];
  if (queryToken != null && queryToken.isNotEmpty) return queryToken;

  if (acceptBare && uri?.hasScheme != true) return trimmed;
  return null;
}
