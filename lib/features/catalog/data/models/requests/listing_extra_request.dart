import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_extra_request.freezed.dart';
part 'listing_extra_request.g.dart';

/// Single add-on inside the `extras` array of a create/update listing
/// request — see `flutter-listings-api.md` §5.1.
///
/// Server assigns `id` and `sortOrder` (from the array position). The
/// client only sends [label], [priceDeltaCents], and optionally
/// [isSelectedByDefault].
@freezed
abstract class ListingExtraRequest with _$ListingExtraRequest {
  const factory ListingExtraRequest({
    required String label,
    required int priceDeltaCents,
    bool? isSelectedByDefault,
  }) = _ListingExtraRequest;

  factory ListingExtraRequest.fromJson(Map<String, dynamic> json) =>
      _$ListingExtraRequestFromJson(json);
}
