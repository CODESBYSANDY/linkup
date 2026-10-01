import 'package:flutter/material.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/onboarding/screens/get_started_screen.dart';
import '../features/onboarding/screens/profile_setup_screen.dart';
import '../features/onboarding/screens/interest_selection_screen.dart';
import '../features/main_navigation/screens/main_navigation_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/search_screen.dart';
import '../features/opportunities/screens/explore_screen.dart';
import '../features/opportunities/screens/saved_opportunities_screen.dart';
import '../features/assistant/screens/riko_assistant_screen.dart';
import '../features/community/screens/community_screen.dart';
import '../features/community/screens/create_post_screen.dart';
import '../features/connect/screens/connect_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/connections_list_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/settings/screens/settings_screen.dart';

/// Centralized route definitions for the application.
abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String profileSetup = '/profile-setup';
  static const String interestSelection = '/interest-selection';
  static const String main = '/main';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String search = '/search';
  static const String savedOpportunities = '/saved-opportunities';
  static const String assistant = '/assistant';
  static const String community = '/community';
  static const String createPost = '/create-post';
  static const String connect = '/connect';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String connections = '/connections';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    onboarding: (context) => const GetStartedScreen(),
    profileSetup: (context) => const ProfileSetupScreen(),
    interestSelection: (context) => const InterestSelectionScreen(),
    main: (context) => const MainNavigationScreen(),
    home: (context) => const HomeScreen(),
    explore: (context) => const ExploreScreen(),
    search: (context) => const SearchScreen(),
    savedOpportunities: (context) => const SavedOpportunitiesScreen(),
    assistant: (context) => const RikoAssistantScreen(),
    community: (context) => const CommunityScreen(),
    createPost: (context) => const CreatePostScreen(),
    connect: (context) => const ConnectScreen(),
    profile: (context) => const ProfileScreen(),
    editProfile: (context) => const EditProfileScreen(),
    connections: (context) => const ConnectionsListScreen(),
    notifications: (context) => const NotificationsScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
