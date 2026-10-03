import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../network/api_exceptions.dart';

/// Centralized API client for communicating with the FastAPI backend.
class ApiClient {
  static final ApiClient instance = ApiClient._();

  ApiClient._() {
    _baseUrl = AppConfig.apiBaseUrl;
  }

  late String _baseUrl;
  String? _authToken;
  Duration timeout = const Duration(seconds: 15);
  final http.Client _client = http.Client();

  void setBaseUrl(String url) => _baseUrl = url;
  void setAuthToken(String? token) => _authToken = token;
  void clearAuthToken() => _authToken = null;

  String get baseUrl => _baseUrl;
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final base = _baseUrl.endsWith('/') ? _baseUrl : '$_baseUrl/';
    final urlString = '$base$cleanPath';

    final uri = Uri.parse(urlString);
    if (queryParams != null && queryParams.isNotEmpty) {
      final sanitized = <String, String>{};
      queryParams.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          sanitized[key] = value.toString();
        }
      });
      return uri.replace(queryParameters: sanitized);
    }
    return uri;
  }

  Future<String?> _resolveToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) {
      return _authToken;
    }
    try {
      if (Firebase.apps.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          if (token != null && token.isNotEmpty) {
            _authToken = token;
            return token;
          }
        }
      }
    } catch (_) {}
    return _authToken;
  }

  Future<Map<String, String>> _buildHeaders({bool isJson = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    final token = await _resolveToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(path, queryParams);
    return _sendRequest(
      () async {
        final headers = await _buildHeaders(isJson: false);
        return _client.get(uri, headers: headers);
      },
      'GET',
      uri,
    );
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendRequest(
      () async {
        final headers = await _buildHeaders();
        return _client.post(uri, headers: headers, body: encodedBody);
      },
      'POST',
      uri,
    );
  }

  Future<dynamic> patch(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendRequest(
      () async {
        final headers = await _buildHeaders();
        return _client.patch(uri, headers: headers, body: encodedBody);
      },
      'PATCH',
      uri,
    );
  }

  Future<dynamic> put(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendRequest(
      () async {
        final headers = await _buildHeaders();
        return _client.put(uri, headers: headers, body: encodedBody);
      },
      'PUT',
      uri,
    );
  }

  Future<dynamic> delete(String path) async {
    final uri = _buildUri(path);
    return _sendRequest(
      () async {
        final headers = await _buildHeaders(isJson: false);
        return _client.delete(uri, headers: headers);
      },
      'DELETE',
      uri,
    );
  }

  /// Checks backend health at /health
  Future<bool> checkHealth() async {
    try {
      final rootUrl = AppConfig.rootBackendUrl;
      final uri = Uri.parse('$rootUrl/health');
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Checks backend database readiness at /health/ready
  Future<bool> checkReadiness() async {
    try {
      final rootUrl = AppConfig.rootBackendUrl;
      final uri = Uri.parse('$rootUrl/health/ready');
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> _sendRequest(
    Future<http.Response> Function() requestFn,
    String method,
    Uri uri,
  ) async {
    try {
      if (AppConfig.enableNetworkLogging) {
        debugPrint('[API] $method -> $uri');
      }

      final response = await requestFn().timeout(timeout);

      if (AppConfig.enableNetworkLogging) {
        debugPrint('[API] ${response.statusCode} <- $method $uri (Bytes: ${response.bodyBytes.length})');
      }

      if (response.statusCode == 401) {
        // Attempt single token refresh retry if user is logged into Firebase
        try {
          if (Firebase.apps.isNotEmpty) {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final freshToken = await user.getIdToken(true);
              if (freshToken != null && freshToken.isNotEmpty) {
                _authToken = freshToken;
                final retryResponse = await requestFn().timeout(timeout);
                return _handleResponse(retryResponse, method, uri);
              }
            }
          }
        } catch (_) {}
      }

      return _handleResponse(response, method, uri);
    } on TimeoutException {
      throw ApiException.timeout();
    } on http.ClientException catch (e) {
      if (AppConfig.enableNetworkLogging) {
        debugPrint('[API ClientException]: ${e.message}');
      }
      throw ApiException.networkError(e.message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkError(e.toString());
    }
  }

  dynamic _handleResponse(http.Response response, String method, Uri uri) {
    final responseBody = response.body;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseBody.isEmpty) return null;
      try {
        return jsonDecode(responseBody);
      } catch (_) {
        return responseBody;
      }
    } else {
      String? rawDetail;
      String? code;
      try {
        final parsed = jsonDecode(responseBody);
        if (parsed is Map) {
          if (parsed['detail'] != null) {
            rawDetail = parsed['detail'].toString();
          } else if (parsed['error'] != null && parsed['error'] is Map) {
            rawDetail = parsed['error']['message']?.toString();
            code = parsed['error']['code']?.toString();
          } else if (parsed['message'] != null) {
            rawDetail = parsed['message'].toString();
          }
        }
      } catch (_) {}

      throw ApiException.fromStatusCode(
        response.statusCode,
        rawDetail: rawDetail,
        code: code,
      );
    }
  }
}
