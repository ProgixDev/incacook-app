import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/auth/kyc_document.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/features/authentication/data/models/requests/create_kyc_document_request.dart';

/// Repository for `/v1/kyc/*`.
///
/// One [submitDocument] call per slot — each is idempotent on
/// `(userId, type)`, so re-uploading the same slot supersedes the
/// previous file and resets `reviewState` to PENDING.
class KycRepository extends GetxService {
  KycRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static KycRepository get instance => Get.find();

  final ApiClient _api;

  /// `POST /v1/kyc/documents` (§3.20). [req.fileUrl] must be the storage
  /// path returned by `UploadsRepository.upload` — the backend rejects
  /// raw URLs.
  Future<KycDocument> submitDocument(CreateKycDocumentRequest req) async {
    final result = await _api.post<KycDocument>(
      '${ApiConstants.apiPrefix}/kyc/documents',
      body: req.toJson(),
      decoder: (json) => KycDocument.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `GET /v1/kyc/documents/me` (§3.21) — every document the caller has
  /// uploaded, one row per slot.
  Future<List<KycDocument>> listMyDocuments() async {
    final result = await _api.get<List<KycDocument>>(
      '${ApiConstants.apiPrefix}/kyc/documents/me',
      decoder: (json) => (json! as List<dynamic>)
          .map((item) => KycDocument.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }
}
