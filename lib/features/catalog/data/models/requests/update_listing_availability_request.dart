import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_listing_availability_request.freezed.dart';
part 'update_listing_availability_request.g.dart';

/// Body of `PATCH /v1/listings/:id/availability` — see
/// `flutter-listings-api.md` §5.4.
///
/// Quick on/off toggle without re-sending the entire listing. No KYC
/// check server-side — sellers can wind down content even after KYC
/// has lapsed.
@freezed
abstract class UpdateListingAvailabilityRequest
    with _$UpdateListingAvailabilityRequest {
  const factory UpdateListingAvailabilityRequest({
    required bool isAvailable,
  }) = _UpdateListingAvailabilityRequest;

  factory UpdateListingAvailabilityRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$UpdateListingAvailabilityRequestFromJson(json);
}
