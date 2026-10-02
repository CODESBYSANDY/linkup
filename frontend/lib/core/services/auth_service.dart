import 'package:flutter/foundation.dart';
import '../../data/models/user_profile.dart';

/// Abstract contract for authentication and user identity management.
/// 
/// This interface allows replacing LocalAuthService with FirebaseAuthService
/// later without changing any frontend presentation code.
abstract class AuthService {
  /// Reactive notifier for authentication and profile updates.
  ValueListenable<UserProfile?> get userNotifier;

  /// The current logged-in user profile, or null if guest/logged out.
  UserProfile? get currentUser;

  /// Whether a user is currently authenticated.
  bool get isLoggedIn;

  /// Initializes authentication state from local storage.
  Future<void> initialize();

  /// Logs in with email and password.
  Future<bool> login(String email, String password);

  /// Quick guest login with demo profile.
  Future<bool> loginAsGuest();

  /// Registers a new user.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  });

  /// Signs in with Google using Firebase Authentication.
  Future<bool> signInWithGoogle();

  /// Starts Firebase phone number verification flow.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String errorMessage) onError,
    void Function(String verificationId)? onAutoVerified,
  });

  /// Completes phone authentication using the received OTP code.
  Future<bool> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Resends OTP to the specified phone number.
  Future<void> resendOtp({
    required String phoneNumber,
    required int? resendToken,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String errorMessage) onError,
  });

  /// Updates profile details (bio, college, branch, year, avatar, interests, skills).
  Future<void> updateProfile(UserProfile updatedProfile);

  /// Synchronizes profile from GET /api/v1/me.
  Future<UserProfile?> syncProfileFromBackend();

  /// Toggles saving an opportunity in the user's saved list.
  Future<bool> toggleSaveOpportunity(String opportunityId);

  /// Toggles saving a post in the user's saved list.
  Future<bool> toggleSavePost(String postId);

  /// Toggles joining/leaving a group.
  Future<bool> toggleJoinGroup(String groupId);

  /// Toggles connecting with a peer/user.
  Future<String> toggleConnectUser(String userId);

  /// Requests mentorship from a mentor.
  Future<bool> requestMentor(String mentorId);

  /// Logs out the user and clears authentication state.
  Future<void> logout();
}
