import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(path, queryParams);
    return _executeRequest((client) => client.getUrl(uri), 'GET', uri);
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    return _executeRequest(
      (client) async {
        final request = await client.postUrl(uri);
        if (body != null) {
          request.headers.contentType = ContentType.json;
          request.write(jsonEncode(body));
        }
        return request;
      },
      'POST',
      uri,
      body,
    );
  }

  Future<dynamic> patch(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    return _executeRequest(
      (client) async {
        final request = await client.patchUrl(uri);
        if (body != null) {
          request.headers.contentType = ContentType.json;
          request.write(jsonEncode(body));
        }
        return request;
      },
      'PATCH',
      uri,
      body,
    );
  }

  Future<dynamic> put(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    return _executeRequest(
      (client) async {
        final request = await client.putUrl(uri);
        if (body != null) {
          request.headers.contentType = ContentType.json;
          request.write(jsonEncode(body));
        }
        return request;
      },
      'PUT',
      uri,
      body,
    );
  }

  Future<dynamic> delete(String path) async {
    final uri = _buildUri(path);
    return _executeRequest((client) => client.deleteUrl(uri), 'DELETE', uri);
  }

  Future<dynamic> _executeRequest(
    Future<HttpClientRequest> Function(HttpClient client) requestBuilder,
    String method,
    Uri uri, [
    dynamic requestBody,
  ]) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      if (AppConfig.enableNetworkLogging) {
        debugPrint('[API] $method -> $uri');
      }

      final request = await requestBuilder(client).timeout(timeout);
      _attachHeaders(request);
      final response = await request.close().timeout(timeout);

      return await _handleResponse(response, method, uri);
    } on TimeoutException {
      throw ApiException.timeout();
    } on SocketException catch (e) {
      if (AppConfig.enableNetworkLogging) {
        debugPrint('[API Offline] SocketException: ${e.message}');
      }
      throw ApiException.networkError();
    } on HttpException catch (e) {
      if (AppConfig.enableNetworkLogging) {
        debugPrint('[API HTTP Exception]: ${e.message}');
      }
      throw ApiException.networkError(e.message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkError(e.toString());
    } finally {
      client.close();
    }
  }

  void _attachHeaders(HttpClientRequest request) {
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (_authToken != null && _authToken!.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_authToken');
    }
  }

  Future<dynamic> _handleResponse(HttpClientResponse response, String method, Uri uri) async {
    final responseBody = await response.transform(utf8.decoder).join();

    if (AppConfig.enableNetworkLogging) {
      debugPrint('[API] ${response.statusCode} <- $method $uri (Bytes: ${responseBody.length})');
    }

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
