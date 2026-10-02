import 'package:flutter/foundation.dart';

/// Centralized runtime configuration for environment parameters.
abstract class AppConfig {
  /// Base API URL for deployed FastAPI backend on Render.
  static const String defaultDeployedApiUrl = 'https://linkup-api-cqp3.onrender.com/api/v1';
  static const String defaultRootBackendUrl = 'https://linkup-api-cqp3.onrender.com';

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

    return defaultDeployedApiUrl;
  }

  /// Root URL of the backend service (e.g. for health checks or docs)
  static String get rootBackendUrl {
    final base = apiBaseUrl;
    if (base.endsWith('/api/v1')) {
      return base.substring(0, base.length - '/api/v1'.length);
    }
    return defaultRootBackendUrl;
  }

  /// Flag indicating if running in release or defined production environment.
  static bool get isProduction => kReleaseMode || _definedBaseUrl.isNotEmpty;

  /// Flag indicating if development network logging is enabled.
  static const bool enableNetworkLogging = kDebugMode;
}
