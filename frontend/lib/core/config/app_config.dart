import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Centralized runtime configuration for environment parameters.
abstract class AppConfig {
  /// Base API URL for FastAPI backend.
  ///
  /// Can be overridden at build / runtime via:
  /// `--dart-define=API_BASE_URL=https://your-backend-url/api/v1`
  static const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_definedBaseUrl.isNotEmpty) {
      final clean = _definedBaseUrl.endsWith('/')
          ? _definedBaseUrl.substring(0, _definedBaseUrl.length - 1)
          : _definedBaseUrl;
      return clean.endsWith('/api/v1') ? clean : '$clean/api/v1';
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }

    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api/v1';
      }
    } catch (_) {}

    return 'http://127.0.0.1:8000/api/v1';
  }

  /// Flag indicating if running in release or defined production environment.
  static bool get isProduction => kReleaseMode || _definedBaseUrl.isNotEmpty;

  /// Flag indicating if development logging is enabled.
  static const bool enableNetworkLogging = kDebugMode;
}
