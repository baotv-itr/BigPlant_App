import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(timeout);
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final mergedHeaders = {'Content-Type': 'application/json', ...?headers};
    final response = await http
        .post(Uri.parse(url), headers: mergedHeaders, body: jsonEncode(body))
        .timeout(timeout);
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = {'msg': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['msg']?.toString() ?? 'Request failed';
    throw ApiException(message: message, statusCode: response.statusCode);
  }
}

class ApiException implements Exception {
  ApiException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
