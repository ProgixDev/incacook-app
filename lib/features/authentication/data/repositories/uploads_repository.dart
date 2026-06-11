import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/authentication/data/models/requests/create_upload_request.dart';

/// Repository for the two-step upload flow (§3.19).
///
/// Step 1: [createUpload] hits the IncaCook backend, which provisions a
/// signed Supabase Storage URL and returns it as [UploadInfo].
/// Step 2: [putFile] uploads the raw bytes directly to that signed URL
/// — bypassing the IncaCook backend entirely.
/// Step 3: caller posts the resulting [UploadInfo.path] to whichever
/// resource endpoint owns the column (e.g. `profilePhotoUrl` on
/// `PUT /v1/sellers/me/profile`).
///
/// The signed PUT uses a bare `Dio` instance — we deliberately skip the
/// auth interceptor since Supabase Storage uses its own token, embedded
/// in the URL.
class UploadsRepository extends GetxService {
  UploadsRepository({ApiClient? api, Dio? rawDio})
    : _api = api ?? Get.find<ApiClient>(),
      _rawDio = rawDio ?? Dio();

  static UploadsRepository get instance => Get.find();

  final ApiClient _api;
  final Dio _rawDio;

  /// Step 1 — `POST /v1/uploads`. Returns the signed URL + storage path.
  Future<UploadInfo> createUpload(CreateUploadRequest req) async {
    final result = await _api.post<UploadInfo>(
      '${ApiConstants.apiPrefix}/uploads',
      body: req.toJson(),
      decoder: (json) => UploadInfo.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// Step 2 — PUT the file body to the signed URL.
  ///
  /// Throws [ApiFailure] on non-2xx. Doesn't go through the IncaCook
  /// envelope — Supabase returns its own JSON shape and we just check
  /// the status code.
  Future<void> putFile({
    required String uploadUrl,
    required Uint8List bytes,
    String? contentType,
  }) async {
    try {
      final response = await _rawDio.put<dynamic>(
        _reachableUploadUrl(uploadUrl),
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            'Content-Type': ?contentType,
            'Content-Length': bytes.length,
          },
        ),
      );
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ApiFailure.transport(
          message: 'Upload PUT failed with $status',
          statusCode: status,
        );
      }
    } on DioException catch (e) {
      throw ApiFailure.transport(
        message: 'Upload PUT failed: ${e.message ?? e.type.name}',
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  /// Loopback hosts that are only reachable from the machine running the
  /// backend — never from an emulator or a physical device.
  static const _loopbackHosts = {'127.0.0.1', 'localhost', '0.0.0.0', '::1'};

  /// In local dev the signed Supabase URL is built from the backend's
  /// `SUPABASE_URL`, a loopback host (e.g. `127.0.0.1:54331`). That host is
  /// unreachable from the device — on the Android emulator `127.0.0.1` is the
  /// emulator itself, so the PUT is refused. When the app talks to the backend
  /// through a non-loopback host (`10.0.2.2` on the emulator, a LAN IP on a
  /// real device), point the upload at that same host, keeping the storage
  /// port and signing query intact. Production URLs (`*.supabase.co`) aren't
  /// loopback, so they pass through untouched.
  String _reachableUploadUrl(String uploadUrl) {
    final target = Uri.parse(uploadUrl);
    if (!_loopbackHosts.contains(target.host)) return uploadUrl;

    final apiHost = Uri.parse(ApiConstants.baseUrl).host;
    if (_loopbackHosts.contains(apiHost)) return uploadUrl; // e.g. iOS simulator

    return target.replace(host: apiHost).toString();
  }

  /// Convenience that does steps 1 + 2 and returns the storage path
  /// ready to be sent to whichever resource endpoint owns the column.
  Future<String> upload({
    required CreateUploadRequest req,
    required Uint8List bytes,
  }) async {
    final info = await createUpload(req);
    await putFile(
      uploadUrl: info.uploadUrl,
      bytes: bytes,
      contentType: req.contentType,
    );
    return info.path;
  }
}
