import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_otp_request.freezed.dart';
part 'request_otp_request.g.dart';

/// Body of `POST /v1/auth/phone/request-otp` (§3.8).
///
/// [phone] is E.164 with leading `+` (e.g. `+33611111111`). Calling with
/// a different phone overwrites the pending one (last-write-wins).
@freezed
abstract class RequestOtpRequest with _$RequestOtpRequest {
  const factory RequestOtpRequest({required String phone}) =
      _RequestOtpRequest;

  factory RequestOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestOtpRequestFromJson(json);
}
