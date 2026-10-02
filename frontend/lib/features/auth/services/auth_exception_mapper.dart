import 'package:firebase_auth/firebase_auth.dart';

/// Reusable utility for converting Firebase and authentication exceptions
/// into clean, actionable, human-readable error messages.
class AuthExceptionMapper {
  AuthExceptionMapper._();

  /// Converts a Firebase authentication exception or generic error into
  /// a polished user-facing message.
  static String toUserMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        // Phone / OTP specific errors
        case 'invalid-phone-number':
          return 'Please enter a valid phone number with country code.';
        case 'invalid-verification-code':
          return 'The verification code entered is incorrect. Please check and try again.';
        case 'invalid-verification-id':
          return 'The verification session has expired. Please request a new code.';
        case 'session-expired':
          return 'Your verification code has expired. Please request a new code.';
        case 'quota-exceeded':
          return 'SMS quota exceeded for today. Please try again later or use Google Sign-In.';
        case 'missing-phone-number':
          return 'Please enter your phone number to continue.';
        case 'missing-verification-code':
          return 'Please enter the 6-digit verification code.';

        // Google / Credential specific errors
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email using a different sign-in method.';
        case 'credential-already-in-use':
          return 'This credential is already linked to another account.';
        case 'popup-closed-by-user':
          return 'Sign-in cancelled. Please complete the prompt to continue.';
        case 'cancelled-popup-request':
          return 'Only one sign-in prompt can be open at a time.';
        case 'popup-blocked':
          return 'The sign-in popup was blocked by your browser. Please allow popups for this site.';

        // General Auth & Network errors
        case 'network-request-failed':
          return 'Network connection failed. Please check your internet connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a few moments and try again.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'operation-not-allowed':
          return 'This sign-in method is currently disabled in your Firebase project.';
        case 'user-not-found':
          return 'No account found with these details.';
        case 'wrong-password':
          return 'Incorrect password. Please verify and try again.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';

        default:
          final msg = error.message;
          if (msg != null && msg.isNotEmpty && !msg.contains('firebase') && !msg.contains('API')) {
            return msg;
          }
          return 'Authentication failed. Please try again.';
      }
    }

    final str = error.toString();
    if (str.contains('SocketException') || str.contains('network') || str.contains('Failed host lookup')) {
      return 'Network connection failed. Please check your internet connection.';
    }
    if (str.contains('canceled') || str.contains('cancelled') || str.contains('User canceled')) {
      return 'Sign-in was cancelled.';
    }

    return 'Something went wrong. Please try again.';
  }
}
