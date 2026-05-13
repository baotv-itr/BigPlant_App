import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../core/auth/auth_session_manager.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/storage_service.dart';

class ScanApi {
  static const String _scanEndpoint = 'api/plant_detect?topk=5&two_pass=true';
  static const String _fileField = 'file';

  Future<Map<String, dynamic>> scanPlant({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final token = await StorageService.getToken();
    final uri = _buildUri();
    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      request.files.add(
        http.MultipartFile.fromBytes(
          _fileField,
          imageBytes,
          filename: fileName,
        ),
      );

      final streamed = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _decode(response.body);
      }

      if (response.statusCode == 401) {
        await AuthSessionManager.handleUnauthorized();
      }

      throw ApiException(
        message: 'Scan failed (${response.statusCode}): ${response.body}',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Scan endpoint unreachable: $e',
        statusCode: 500,
      );
    }
  }

  Uri _buildUri() {
    final base = ApiConstants.baseUrl;
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    return Uri.parse('$normalizedBase$_scanEndpoint');
  }

  Map<String, dynamic> _decode(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final parsed = jsonDecode(responseBody);
    if (parsed is Map<String, dynamic>) {
      return parsed;
    }
    if (parsed is Map) {
      return parsed.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{'result': parsed};
  }
}
