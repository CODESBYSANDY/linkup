import 'package:flutter/material.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/user_profile.dart';
import '../../main_navigation/screens/main_navigation_screen.dart';
import '../screens/login_screen.dart';

/// Reactive Authentication Gate that listens to user authentication state.
///
/// If user is authenticated, presents [MainNavigationScreen].
/// If user is not authenticated, presents [LoginScreen].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: AppServices.auth.userNotifier,
      builder: (context, user, _) {
        if (AppServices.auth.isLoggedIn || user != null) {
          return const MainNavigationScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
