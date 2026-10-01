import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme/app_theme.dart';
import '../core/services/app_services.dart';

/// Root application widget configuring global theme and routing.
class LinkUpApp extends StatelessWidget {
  const LinkUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppServices.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'LINKUP',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
