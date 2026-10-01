import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import '../../data/repositories/local_auth_service.dart';
import '../../data/repositories/opportunity_repository.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/repositories/connect_repository.dart';
import '../../data/repositories/notification_repository.dart';

/// Centralized service container for LinkUp application.
class AppServices {
  static final StorageService storage = StorageService();
  static late AuthService auth;
  static late OpportunityRepository opportunities;
  static late CommunityRepository community;
  static late ConnectRepository connect;
  static late NotificationRepository notifications;
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

  static const String _themeModeKey = 'linkup_theme_mode_v2';
  static bool _initialized = false;

  /// Initializes all core application services.
  static Future<void> init() async {
    if (!_initialized) {
      await storage.init();
      auth = LocalAuthService(storage);
      opportunities = OpportunityRepository();
      community = CommunityRepository();
      connect = ConnectRepository();
      notifications = NotificationRepository();
      _initialized = true;
    }
    await auth.initialize();

    // Load saved theme preference
    final savedTheme = storage.getString(_themeModeKey);
    if (savedTheme == 'dark') {
      themeModeNotifier.value = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      themeModeNotifier.value = ThemeMode.light;
    } else {
      themeModeNotifier.value = ThemeMode.dark;
    }
  }

  /// Sets and persists theme mode preference.
  static Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await storage.setString(_themeModeKey, modeString);
  }
}
