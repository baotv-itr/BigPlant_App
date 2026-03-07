import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/storage_service.dart';

class ScanApi {
  static const List<String> _endpointCandidates = [
    'api/plant/scan',
    'api/plants/scan',
    'api/scan',
    'predict/file',
    'predict',
  ];

  static const List<String> _fileFieldCandidates = ['image', 'file', 'plant_image'];

  Future<Map<String, dynamic>> scanPlant({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final token = await StorageService.getToken();
    final errors = <String>[];

    for (final endpoint in _endpointCandidates) {
      for (final fileField in _fileFieldCandidates) {
        final uri = _buildUri(endpoint);
        try {
          final request = http.MultipartRequest('POST', uri);
          request.headers.addAll({
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          });
          request.files.add(
            http.MultipartFile.fromBytes(
              fileField,
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

          errors.add(
            '${response.statusCode} ${uri.path} field=$fileField',
          );
        } catch (e) {
          errors.add('$endpoint field=$fileField: $e');
        }
      }
    }

    throw ApiException(
      message: 'Scan endpoint unreachable. Tried: ${errors.take(4).join(' | ')}',
      statusCode: 500,
    );
  }

  Uri _buildUri(String endpoint) {
    final base = ApiConstants.baseScanUrl;
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    return Uri.parse('$normalizedBase$endpoint');
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
