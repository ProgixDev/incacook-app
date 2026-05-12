import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/models/auth/upload_info.dart';

part 'create_upload_request.freezed.dart';
part 'create_upload_request.g.dart';

/// Body of `POST /v1/uploads` (§3.19). Returns an [UploadInfo] with the
/// signed URL the client PUTs the file body to.
@freezed
abstract class CreateUploadRequest with _$CreateUploadRequest {
  const factory CreateUploadRequest({
    required UploadPurpose purpose,
    String? contentType,
  }) = _CreateUploadRequest;

  factory CreateUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUploadRequestFromJson(json);
}
