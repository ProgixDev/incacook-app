import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/models/auth/kyc_document.dart';
import 'package:incacook/features/authentication/data/models/id_document_type.dart';

part 'create_kyc_document_request.freezed.dart';
part 'create_kyc_document_request.g.dart';

/// Body of `POST /v1/kyc/documents` (§3.20). Idempotent on
/// `(userId, type)` — re-posting for the same slot supersedes the
/// previous and resets `reviewState` to PENDING.
///
/// [idDocumentType] is required only when [type] is ID_FRONT or ID_BACK;
/// SELFIE / DRIVING_LICENSE / CARTE_GRISE / INSURANCE leave it null.
@freezed
abstract class CreateKycDocumentRequest with _$CreateKycDocumentRequest {
  const factory CreateKycDocumentRequest({
    required KycDocumentType type,
    required String fileUrl, // /v1/uploads path
    IdDocumentType? idDocumentType,
  }) = _CreateKycDocumentRequest;

  factory CreateKycDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateKycDocumentRequestFromJson(json);
}
