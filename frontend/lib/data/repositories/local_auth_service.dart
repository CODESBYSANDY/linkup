import 'package:flutter/foundation.dart';
import '../../core/services/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../models/user_profile.dart';

/// Authentication and Profile management service backed by FastAPI / PostgreSQL.
class LocalAuthService implements AuthService {
  final StorageService _storage;
  final ValueNotifier<UserProfile?> _userNotifier = ValueNotifier<UserProfile?>(null);

  static const String _userKey = 'linkup_current_user_v3';
  static const String _isLoggedInKey = 'linkup_is_logged_in_v3';
  static const String _tokenKey = 'linkup_auth_token_v3';

  LocalAuthService(this._storage);

  @override
  ValueListenable<UserProfile?> get userNotifier => _userNotifier;

  @override
  UserProfile? get currentUser => _userNotifier.value;

  @override
  bool get isLoggedIn => _storage.getBool(_isLoggedInKey) ?? false;

  @override
  Future<void> initialize() async {
    final loggedIn = _storage.getBool(_isLoggedInKey) ?? false;
    final savedToken = _storage.getString(_tokenKey);

    if (savedToken != null && savedToken.isNotEmpty) {
      ApiClient.instance.setAuthToken(savedToken);
    }

    if (loggedIn) {
      final userJson = _storage.getJson(_userKey);
      if (userJson != null) {
        _userNotifier.value = UserProfile.fromJson(userJson);
      }

      // Sync latest profile from FastAPI backend
      await syncProfileFromBackend();
    } else {
      _userNotifier.value = null;
    }
  }

  /// Syncs authenticated user profile from GET /api/v1/me.
  @override
  Future<UserProfile?> syncProfileFromBackend() async {
    try {
      final response = await ApiClient.instance.get('me');
      if (response is Map<String, dynamic>) {
        final profile = UserProfile.fromJson(response);
        _userNotifier.value = profile;
        await _storage.setJson(_userKey, profile.toJson());
        return profile;
      }
    } catch (e) {
      debugPrint('[AuthService] Backend profile sync skipped / offline: $e');
    }
    return _userNotifier.value;
  }

  @override
  Future<bool> login(String email, String password) async {
    // Session token generated for Firebase / FastAPI authentication
    final token = 'session_token_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    ApiClient.instance.setAuthToken(token);
    await _storage.setString(_tokenKey, token);

    try {
      final response = await ApiClient.instance.get('me');
      if (response is Map<String, dynamic>) {
        final profile = UserProfile.fromJson(response);
        _userNotifier.value = profile;
        await _storage.setBool(_isLoggedInKey, true);
        await _storage.setJson(_userKey, profile.toJson());
        return true;
      }
    } catch (e) {
      debugPrint('[AuthService] Direct login backend sync notice: $e');
    }

    // Fallback local profile initialization if backend is offline
    final initials = email.isNotEmpty ? email.substring(0, 1).toUpperCase() : 'SU';
    final name = email.split('@').first.replaceAll('.', ' ');
    final formattedName = name.isNotEmpty
        ? name[0].toUpperCase() + name.substring(1)
        : 'Student User';

    final profile = UserProfile.defaultDemo().copyWith(
      name: formattedName,
      email: email,
      avatarInitials: initials,
      isOnboarded: true,
    );

    _userNotifier.value = profile;
    await _storage.setBool(_isLoggedInKey, true);
    await _storage.setJson(_userKey, profile.toJson());
    return true;
  }

  @override
  Future<bool> loginAsGuest() async {
    const token = 'session_token_guest_student';
    ApiClient.instance.setAuthToken(token);
    await _storage.setString(_tokenKey, token);

    try {
      final response = await ApiClient.instance.get('me');
      if (response is Map<String, dynamic>) {
        final profile = UserProfile.fromJson(response);
        _userNotifier.value = profile;
        await _storage.setBool(_isLoggedInKey, true);
        await _storage.setJson(_userKey, profile.toJson());
        return true;
      }
    } catch (_) {}

    final guestProfile = UserProfile.defaultDemo().copyWith(isOnboarded: true);
    _userNotifier.value = guestProfile;
    await _storage.setBool(_isLoggedInKey, true);
    await _storage.setJson(_userKey, guestProfile.toJson());
    return true;
  }

  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final token = 'session_token_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    ApiClient.instance.setAuthToken(token);
    await _storage.setString(_tokenKey, token);

    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'SU';

    final newProfile = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      avatarInitials: initials.isNotEmpty ? initials : 'SU',
      isOnboarded: false,
    );

    _userNotifier.value = newProfile;
    await _storage.setBool(_isLoggedInKey, true);
    await _storage.setJson(_userKey, newProfile.toJson());

    // Attempt provisioning via PATCH /me
    try {
      await updateProfile(newProfile);
    } catch (_) {}

    return true;
  }

  @override
  Future<bool> signInWithGoogle() async {
    return loginAsGuest();
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String errorMessage) onError,
    void Function(String verificationId)? onAutoVerified,
  }) async {
    onCodeSent('mock_verification_id', 12345);
  }

  @override
  Future<bool> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    return loginAsGuest();
  }

  @override
  Future<void> resendOtp({
    required String phoneNumber,
    required int? resendToken,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String errorMessage) onError,
  }) async {
    onCodeSent('mock_verification_id_resend', 12345);
  }

  @override
  Future<void> updateProfile(UserProfile updatedProfile) async {
    _userNotifier.value = updatedProfile;
    await _storage.setJson(_userKey, updatedProfile.toJson());

    try {
      final payload = {
        'name': updatedProfile.name,
        'college': updatedProfile.college,
        'branch': updatedProfile.branch,
        'year': updatedProfile.year,
        'bio': updatedProfile.bio,
        'avatar_initials': updatedProfile.avatarInitials,
        'skills': updatedProfile.skills,
        'interests': updatedProfile.interests,
        'is_onboarded': updatedProfile.isOnboarded,
      };

      final response = await ApiClient.instance.patch('me', body: payload);
      if (response is Map<String, dynamic>) {
        final serverProfile = UserProfile.fromJson(response);
        _userNotifier.value = serverProfile;
        await _storage.setJson(_userKey, serverProfile.toJson());
      }
    } catch (e) {
      debugPrint('[AuthService] Backend profile update error: $e');
    }
  }

  @override
  Future<bool> toggleSaveOpportunity(String opportunityId) async {
    final user = _userNotifier.value;
    if (user == null) return false;

    final currentSaved = List<String>.from(user.savedOpportunityIds);
    final isSaved = currentSaved.contains(opportunityId);

    // Optimistic UI update
    if (isSaved) {
      currentSaved.remove(opportunityId);
    } else {
      currentSaved.add(opportunityId);
    }

    final updated = user.copyWith(savedOpportunityIds: currentSaved);
    _userNotifier.value = updated;
    await _storage.setJson(_userKey, updated.toJson());

    try {
      final response = await ApiClient.instance.post('opportunities/$opportunityId/save');
      if (response is Map && response['is_saved'] != null) {
        return response['is_saved'] as bool;
      }
    } catch (e) {
      debugPrint('[AuthService] Backend save opportunity toggle error: $e');
    }

    return !isSaved;
  }

  @override
  Future<bool> toggleSavePost(String postId) async {
    final user = _userNotifier.value;
    if (user == null) return false;

    final currentSaved = List<String>.from(user.savedPostIds);
    final isSaved = currentSaved.contains(postId);

    if (isSaved) {
      currentSaved.remove(postId);
    } else {
      currentSaved.add(postId);
    }

    final updated = user.copyWith(savedPostIds: currentSaved);
    _userNotifier.value = updated;
    await _storage.setJson(_userKey, updated.toJson());

    try {
      final response = await ApiClient.instance.post('posts/$postId/save');
      if (response is Map && response['is_saved'] != null) {
        return response['is_saved'] as bool;
      }
    } catch (e) {
      debugPrint('[AuthService] Backend save post toggle error: $e');
    }

    return !isSaved;
  }

  @override
  Future<bool> toggleJoinGroup(String groupId) async {
    final user = _userNotifier.value;
    if (user == null) return false;

    final currentGroups = List<String>.from(user.joinedGroupIds);
    final isJoined = currentGroups.contains(groupId);

    if (isJoined) {
      currentGroups.remove(groupId);
    } else {
      currentGroups.add(groupId);
    }

    final updated = user.copyWith(joinedGroupIds: currentGroups);
    _userNotifier.value = updated;
    await _storage.setJson(_userKey, updated.toJson());

    try {
      final response = await ApiClient.instance.post('groups/$groupId/join');
      if (response is Map && response['is_joined'] != null) {
        return response['is_joined'] as bool;
      }
    } catch (e) {
      debugPrint('[AuthService] Backend toggle join group error: $e');
    }

    return !isJoined;
  }

  @override
  Future<String> toggleConnectUser(String userId) async {
    final user = _userNotifier.value;
    if (user == null) return 'None';

    final currentPending = List<String>.from(user.pendingConnectionIds);
    final currentConnected = List<String>.from(user.connectedUserIds);

    String newState = 'PENDING';
    if (currentConnected.contains(userId)) {
      currentConnected.remove(userId);
      newState = 'NONE';
    } else if (currentPending.contains(userId)) {
      currentPending.remove(userId);
      newState = 'NONE';
    } else {
      currentPending.add(userId);
      newState = 'PENDING';
    }

    final updated = user.copyWith(
      pendingConnectionIds: currentPending,
      connectedUserIds: currentConnected,
    );
    _userNotifier.value = updated;
    await _storage.setJson(_userKey, updated.toJson());

    try {
      final response = await ApiClient.instance.post('connections/$userId');
      if (response is Map && response['status'] != null) {
        final serverStatus = response['status'].toString();
        if (serverStatus == 'ACCEPTED') {
          currentPending.remove(userId);
          if (!currentConnected.contains(userId)) currentConnected.add(userId);
        } else if (serverStatus == 'PENDING') {
          if (!currentPending.contains(userId)) currentPending.add(userId);
          currentConnected.remove(userId);
        } else {
          currentPending.remove(userId);
          currentConnected.remove(userId);
        }
        final finalProfile = user.copyWith(
          pendingConnectionIds: currentPending,
          connectedUserIds: currentConnected,
        );
        _userNotifier.value = finalProfile;
        await _storage.setJson(_userKey, finalProfile.toJson());
        return serverStatus;
      }
    } catch (e) {
      debugPrint('[AuthService] Backend toggle connect error: $e');
    }

    return newState;
  }

  @override
  Future<bool> requestMentor(String mentorId) async {
    final user = _userNotifier.value;
    if (user == null) return false;

    final currentRequests = List<String>.from(user.requestedMentorIds);
    final isRequested = currentRequests.contains(mentorId);

    if (isRequested) {
      currentRequests.remove(mentorId);
    } else {
      currentRequests.add(mentorId);
    }

    final updated = user.copyWith(requestedMentorIds: currentRequests);
    _userNotifier.value = updated;
    await _storage.setJson(_userKey, updated.toJson());

    try {
      final response = await ApiClient.instance.post('mentors/$mentorId/request');
      if (response is Map && response['is_requested'] != null) {
        return response['is_requested'] as bool;
      }
    } catch (e) {
      debugPrint('[AuthService] Backend mentor request error: $e');
    }

    return !isRequested;
  }

  @override
  Future<void> logout() async {
    ApiClient.instance.setAuthToken(null);
    _userNotifier.value = null;
    await _storage.remove(_userKey);
    await _storage.remove(_isLoggedInKey);
    await _storage.remove(_tokenKey);
  }
}
