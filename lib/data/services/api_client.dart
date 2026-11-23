import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';

/// Stateless HTTP client wrapper matching the Postman collection's `token` header convention.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 25);

  String? _token;

  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _buildHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _token != null && _token!.isNotEmpty) {
      headers['token'] = _token!;
    }
    return headers;
  }

  Uri _buildUri(String url, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse(url);
    if (queryParams == null || queryParams.isEmpty) return uri;
    final cleanParams = <String, String>{};
    queryParams.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        cleanParams[key] = value.toString();
      }
    });
    return uri.replace(queryParameters: cleanParams);
  }

  Future<ApiResponse<dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParams,
    bool includeAuth = true,
  }) async {
    return _send(
      () => _client
          .get(
            _buildUri(url, queryParams),
            headers: _buildHeaders(includeAuth: includeAuth),
          )
          .timeout(_timeout),
    );
  }

  Future<ApiResponse<dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    return _send(
      () => _client
          .post(
            Uri.parse(url),
            headers: _buildHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout),
    );
  }

  Future<ApiResponse<dynamic>> patch(
    String url, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    return _send(
      () => _client
          .patch(
            Uri.parse(url),
            headers: _buildHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout),
    );
  }

  Future<ApiResponse<dynamic>> delete(
    String url, {
    bool includeAuth = true,
  }) async {
    return _send(
      () => _client
          .delete(
            Uri.parse(url),
            headers: _buildHeaders(includeAuth: includeAuth),
          )
          .timeout(_timeout),
    );
  }

  Future<ApiResponse<dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request();
      dynamic decoded;
      if (response.body.isNotEmpty) {
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {
          decoded = response.body;
        }
      }

      String message = 'Request completed';
      dynamic data = decoded;

      if (decoded is Map<String, dynamic>) {
        message = (decoded['msg'] ?? decoded['message'] ?? message).toString();
        data = decoded.containsKey('data') ? decoded['data'] : decoded;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          statusCode: response.statusCode,
          message: message,
          data: data,
        );
      }

      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: message == 'Request completed'
            ? 'Request failed (${response.statusCode})'
            : message,
      );
    } on SocketException {
      return ApiResponse.failure(
        statusCode: -1,
        message: 'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      return ApiResponse.failure(
        statusCode: -1,
        message: 'Request timed out. The server may be waking up, please retry.',
      );
    } catch (e) {
      return ApiResponse.failure(
        statusCode: -1,
        message: e.toString(),
      );
    }
  }
}
