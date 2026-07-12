import 'package:freezed_annotation/freezed_annotation.dart';

part 'zone.freezed.dart';
part 'zone.g.dart';

/// A delivery operating zone as returned by `GET /v1/zones` (public,
/// active zones only). Backing table introduced in the 2026-07-05 zones
/// module. Drivers pick from these during signup; the selection is saved
/// back to `PUT /v1/drivers/me/zones` as free-text [name]s (§3.18).
@freezed
abstract class Zone with _$Zone {
  const factory Zone({
    required String id,
    required String name,
    @Default(0) int displayOrder,
    @Default(true) bool isActive,
    String? city,
    double? lat,
    double? lng,
  }) = _Zone;

  factory Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);
}
