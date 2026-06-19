import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_info.freezed.dart';
part 'upload_info.g.dart';

/// What kind of asset is being uploaded. The backend role-gates each
/// purpose (see §3.19 "Role gates"). Wire format is lowercase here
/// because the doc literally shows `"avatar"`, not `"AVATAR"`.
enum UploadPurpose {
  @JsonValue('avatar')
  avatar,
  @JsonValue('kyc_document')
  kycDocument,
  @JsonValue('listing_image')
  listingImage,
  @JsonValue('seller_facade')
  sellerFacade,
  @JsonValue('delivery_proof')
  deliveryProof,
}

/// Response of `POST /v1/uploads` (§3.19).
///
/// The client then PUTs the file body directly to [uploadUrl]; on
/// success, it sends [path] back to the resource endpoint that owns the
/// column (avatar path on /v1/sellers/me/profile, fileUrl on
/// /v1/kyc/documents, etc.). Don't expose [token] outside the upload
/// pipeline — it's the bearer for the signed URL, included for
/// completeness.
@freezed
abstract class UploadInfo with _$UploadInfo {
  const factory UploadInfo({
    required String uploadUrl,
    required String token,
    required String path,
    required String bucket,
  }) = _UploadInfo;

  factory UploadInfo.fromJson(Map<String, dynamic> json) =>
      _$UploadInfoFromJson(json);
}
