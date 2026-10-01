import 'package:flutter/foundation.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../models/user_profile.dart';

/// Local mock implementation of AuthService with persistent state.
class LocalAuthService implements AuthService {
  final StorageService _storage;
  final ValueNotifier<UserProfile?> _userNotifier = ValueNotifier<UserProfile?>(null);

  static const String _userKey = 'linkup_current_user_v2';
  static const String _isLoggedInKey = 'linkup_is_logged_in_v2';

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
    if (loggedIn) {
      final userJson = _storage.getJson(_userKey);
      if (userJson != null) {
        _userNotifier.value = UserProfile.fromJson(userJson);
      } else {
        // Default to demo profile if json missing
        final demo = UserProfile.defaultDemo();
        _userNotifier.value = demo;
        await _storage.setJson(_userKey, demo.toJson());
      }
    } else {
      _userNotifier.value = null;
    }
  }

  @override
  Future<bool> login(String email, String password) async {
    // For local prototype: accept any valid-looking credentials
    final initials = email.isNotEmpty ? email.substring(0, 1).toUpperCase() : 'SU';
    final name = email.split('@').first.replaceAll('.', ' ');
    final formattedName = name.isNotEmpty
        ? name[0].toUpperCase() + name.substring(1)
        : 'Student User';

    // If previously saved user matches, reload it; otherwise create clean session
    final existingJson = _storage.getJson(_userKey);
    UserProfile profile;
    if (existingJson != null) {
      profile = UserProfile.fromJson(existingJson).copyWith(
        email: email,
      );
    } else {
      profile = UserProfile.defaultDemo().copyWith(
        name: formattedName,
        email: email,
        avatarInitials: initials,
        isOnboarded: true,
      );
    }

    _userNotifier.value = profile;
    await _storage.setBool(_isLoggedInKey, true);
    await _storage.setJson(_userKey, profile.toJson());
    return true;
  }

  @override
  Future<bool> loginAsGuest() async {
    final demo = UserProfile.defaultDemo();
    _userNotifier.value = demo;
    await _storage.setBool(_isLoggedInKey, true);
    await _storage.setJson(_userKey, demo.toJson());
    return true;
  }

  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();
    final newProfile = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      avatarInitials: initials.isNotEmpty ? initials : 'SU',
      college: '',
      branch: '',
      year: 'Year 1',
      bio: '',
      skills: const [],
      interests: const [],
      savedOpportunityIds: const [],
      savedPostIds: const [],
      joinedGroupIds: const [],
      connectedUserIds: const [],
      pendingConnectionIds: const [],
      requestedMentorIds: const [],
      isOnboarded: false, // will proceed to onboarding
    );

    _userNotifier.value = newProfile;
    await _storage.setBool(_isLoggedInKey, true);
    await _storage.setJson(_userKey, newProfile.toJson());
    return true;
  }

  @override
  Future<void> updateProfile(UserProfile updatedProfile) async {
    _userNotifier.value = updatedProfile;
    await _storage.setJson(_userKey, updatedProfile.toJson());
  }

  @override
  Future<bool> toggleSaveOpportunity(String opportunityId) async {
    final user = currentUser ?? UserProfile.defaultDemo();
    final currentSaved = List<String>.from(user.savedOpportunityIds);
    bool isNowSaved;
    if (currentSaved.contains(opportunityId)) {
      currentSaved.remove(opportunityId);
      isNowSaved = false;
    } else {
      currentSaved.add(opportunityId);
      isNowSaved = true;
    }

    final updated = user.copyWith(savedOpportunityIds: currentSaved);
    await updateProfile(updated);
    return isNowSaved;
  }

  @override
  Future<bool> toggleSavePost(String postId) async {
    final user = currentUser ?? UserProfile.defaultDemo();
    final currentSaved = List<String>.from(user.savedPostIds);
    bool isNowSaved;
    if (currentSaved.contains(postId)) {
      currentSaved.remove(postId);
      isNowSaved = false;
    } else {
      currentSaved.add(postId);
      isNowSaved = true;
    }

    final updated = user.copyWith(savedPostIds: currentSaved);
    await updateProfile(updated);
    return isNowSaved;
  }

  @override
  Future<bool> toggleJoinGroup(String groupId) async {
    final user = currentUser ?? UserProfile.defaultDemo();
    final currentGroups = List<String>.from(user.joinedGroupIds);
    bool isNowJoined;
    if (currentGroups.contains(groupId)) {
      currentGroups.remove(groupId);
      isNowJoined = false;
    } else {
      currentGroups.add(groupId);
      isNowJoined = true;
    }

    final updated = user.copyWith(joinedGroupIds: currentGroups);
    await updateProfile(updated);
    return isNowJoined;
  }

  @override
  Future<String> toggleConnectUser(String userId) async {
    final user = currentUser ?? UserProfile.defaultDemo();
    final connected = List<String>.from(user.connectedUserIds);
    final pending = List<String>.from(user.pendingConnectionIds);

    String newState;
    if (connected.contains(userId)) {
      connected.remove(userId);
      newState = 'Connect';
    } else if (pending.contains(userId)) {
      pending.remove(userId);
      connected.add(userId);
      newState = 'Connected';
    } else {
      pending.add(userId);
      newState = 'Pending';
    }

    final updated = user.copyWith(
      connectedUserIds: connected,
      pendingConnectionIds: pending,
    );
    await updateProfile(updated);
    return newState;
  }

  @override
  Future<bool> requestMentor(String mentorId) async {
    final user = currentUser ?? UserProfile.defaultDemo();
    final requested = List<String>.from(user.requestedMentorIds);
    bool isRequested;
    if (requested.contains(mentorId)) {
      requested.remove(mentorId);
      isRequested = false;
    } else {
      requested.add(mentorId);
      isRequested = true;
    }

    final updated = user.copyWith(requestedMentorIds: requested);
    await updateProfile(updated);
    return isRequested;
  }

  @override
  Future<void> logout() async {
    _userNotifier.value = null;
    await _storage.setBool(_isLoggedInKey, false);
    await _storage.remove(_userKey);
  }
}
