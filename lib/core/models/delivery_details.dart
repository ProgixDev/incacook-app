import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incacook/core/models/address.dart';

part 'delivery_details.freezed.dart';
part 'delivery_details.g.dart';

enum DeliveryTiming { asap, scheduled }

@freezed
abstract class DeliveryDetails with _$DeliveryDetails {
  const factory DeliveryDetails({
    required Address address,
    required String instructions,
    required DeliveryTiming timing,
    DateTime? scheduledAt,
    /// Buyer's display name — shown to the driver as the recipient at
    /// the dropoff. Null when not resolved (e.g. buyer-side views).
    String? recipientName,
  }) = _DeliveryDetails;

  factory DeliveryDetails.fromJson(Map<String, dynamic> json) =>
      _$DeliveryDetailsFromJson(json);
}
