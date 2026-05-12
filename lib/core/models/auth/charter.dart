import 'package:freezed_annotation/freezed_annotation.dart';

part 'charter.freezed.dart';
part 'charter.g.dart';

/// The charters tracked by §3.10 / §3.11.
///
/// CGU and CGV are recorded as flat booleans on Gate 2 (`POST /v1/users`)
/// and additionally as versioned acceptances here so we can prove which
/// version of the text the user agreed to. The role-specific charters
/// (HYGIENE, FAIT_MAISON, PUNCTUALITY, CARE) are only accepted via this
/// versioned endpoint — they're not part of Gate 2's body.
enum Charter {
  @JsonValue('CGU')
  cgu,
  @JsonValue('CGV')
  cgv,
  @JsonValue('HYGIENE')
  hygiene,
  @JsonValue('FAIT_MAISON')
  faitMaison,
  @JsonValue('PUNCTUALITY')
  punctuality,
  @JsonValue('CARE')
  care,
}

/// Response of `GET /v1/charters/active` (§3.10). Keys are uppercase
/// charter codes; values are the current version strings the client must
/// echo back when accepting.
///
/// Modelled as a flat map rather than a freezed class because the set of
/// charters is small and stable but evolves — extending the doc with a
/// new charter shouldn't require a Flutter PR.
class ActiveCharters {
  const ActiveCharters(this._byCode);

  factory ActiveCharters.fromJson(Map<String, dynamic> json) {
    return ActiveCharters(
      json.map((k, v) => MapEntry(k, v as String)),
    );
  }

  final Map<String, String> _byCode;

  /// Returns the active version for [charter], or null if the backend
  /// hasn't shipped it yet. Match by the enum's wire value (uppercase).
  String? versionFor(Charter charter) => _byCode[_wire(charter)];

  String _wire(Charter c) => switch (c) {
    Charter.cgu => 'CGU',
    Charter.cgv => 'CGV',
    Charter.hygiene => 'HYGIENE',
    Charter.faitMaison => 'FAIT_MAISON',
    Charter.punctuality => 'PUNCTUALITY',
    Charter.care => 'CARE',
  };

  Map<String, String> toJson() => Map.unmodifiable(_byCode);
}

/// Response of `POST /v1/users/me/charters` (§3.11).
@freezed
abstract class CharterAcceptance with _$CharterAcceptance {
  const factory CharterAcceptance({
    required Charter charter,
    required String version,
    required String acceptedAt,
  }) = _CharterAcceptance;

  factory CharterAcceptance.fromJson(Map<String, dynamic> json) =>
      _$CharterAcceptanceFromJson(json);
}
