import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/features/authentication/data/models/id_document_type.dart';

part 'kyc_document.freezed.dart';
part 'kyc_document.g.dart';

/// The kind of KYC asset a row stores. The wizard maps each upload slot
/// to one of these — fait-maison sellers don't submit any.
enum KycDocumentType {
  @JsonValue('ID_FRONT')
  idFront,
  @JsonValue('ID_BACK')
  idBack,
  @JsonValue('SELFIE')
  selfie,
  @JsonValue('DRIVING_LICENSE')
  drivingLicense,
  @JsonValue('CARTE_GRISE')
  carteGrise,
  @JsonValue('INSURANCE')
  insurance,
}

/// Per-document review state, set by admin tooling.
enum KycReviewState {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
}

/// One row returned by `POST /v1/kyc/documents` (§3.20) and listed by
/// `GET /v1/kyc/documents/me` (§3.21). Idempotent on `(userId, type)` —
/// a new upload for the same slot supersedes the previous.
@freezed
abstract class KycDocument with _$KycDocument {
  const factory KycDocument({
    required String id,
    required KycDocumentType type,
    required String fileUrl,
    required KycReviewState reviewState,
    String? rejectionReason,
    required String submittedAt,
    String? reviewedAt,
    KycDocumentMetadata? metadata,
  }) = _KycDocument;

  factory KycDocument.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentFromJson(json);
}

/// Slot-specific extras. Today the only field is the `idDocumentType` set
/// on ID_FRONT / ID_BACK rows; future slots may add more.
@freezed
abstract class KycDocumentMetadata with _$KycDocumentMetadata {
  const factory KycDocumentMetadata({IdDocumentType? idDocumentType}) =
      _KycDocumentMetadata;

  factory KycDocumentMetadata.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentMetadataFromJson(json);
}
