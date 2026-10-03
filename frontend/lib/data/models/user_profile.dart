/// Model representing a student user profile in LinkUp, synchronized with FastAPI backend schema.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String college;
  final String branch;
  final String year;
  final String bio;
  final String avatarInitials;
  final String? avatarUrl;
  final List<String> skills;
  final List<String> interests;
  final List<String> savedOpportunityIds;
  final List<String> savedPostIds;
  final List<String> joinedGroupIds;
  final List<String> connectedUserIds;
  final List<String> pendingConnectionIds;
  final List<String> requestedMentorIds;
  final bool isOnboarded;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'USER',
    this.college = '',
    this.branch = '',
    this.year = 'Year 1',
    this.bio = '',
    this.avatarInitials = 'SU',
    this.avatarUrl,
    this.skills = const [],
    this.interests = const [],
    this.savedOpportunityIds = const [],
    this.savedPostIds = const [],
    this.joinedGroupIds = const [],
    this.connectedUserIds = const [],
    this.pendingConnectionIds = const [],
    this.requestedMentorIds = const [],
    this.isOnboarded = false,
    this.createdAt,
  });

  /// Default demo user profile for quick login / guest access.
  factory UserProfile.defaultDemo() {
    return UserProfile(
      id: 'guest_student',
      name: 'Guest Student',
      email: 'guest@student.linkup.dev',
      role: 'USER',
      college: '',
      branch: '',
      year: 'Year 1',
      bio: '',
      avatarInitials: 'GS',
      skills: const [],
      interests: const [],
      savedOpportunityIds: const [],
      savedPostIds: const [],
      joinedGroupIds: const [],
      connectedUserIds: const [],
      pendingConnectionIds: const [],
      requestedMentorIds: const [],
      isOnboarded: false,
      createdAt: DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? college,
    String? branch,
    String? year,
    String? bio,
    String? avatarInitials,
    String? avatarUrl,
    List<String>? skills,
    List<String>? interests,
    List<String>? savedOpportunityIds,
    List<String>? savedPostIds,
    List<String>? joinedGroupIds,
    List<String>? connectedUserIds,
    List<String>? pendingConnectionIds,
    List<String>? requestedMentorIds,
    bool? isOnboarded,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      bio: bio ?? this.bio,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      savedOpportunityIds: savedOpportunityIds ?? this.savedOpportunityIds,
      savedPostIds: savedPostIds ?? this.savedPostIds,
      joinedGroupIds: joinedGroupIds ?? this.joinedGroupIds,
      connectedUserIds: connectedUserIds ?? this.connectedUserIds,
      pendingConnectionIds: pendingConnectionIds ?? this.pendingConnectionIds,
      requestedMentorIds: requestedMentorIds ?? this.requestedMentorIds,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'college': college,
      'branch': branch,
      'year': year,
      'bio': bio,
      'avatar_initials': avatarInitials,
      'avatar_url': avatarUrl,
      'skills': skills,
      'interests': interests,
      'saved_opportunity_ids': savedOpportunityIds,
      'saved_post_ids': savedPostIds,
      'joined_group_ids': joinedGroupIds,
      'connected_user_ids': connectedUserIds,
      'pending_connection_ids': pendingConnectionIds,
      'requested_mentor_ids': requestedMentorIds,
      'is_onboarded': isOnboarded,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null || json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '');
      } catch (_) {}
    }

    final rawName = json['full_name'] as String? ?? json['name'] as String? ?? 'Student User';
    final rawBranch = json['department'] as String? ?? json['branch'] as String? ?? 'Computer Science & Engineering';

    String initials = 'SU';
    if (json['avatar_initials'] != null || json['avatarInitials'] != null) {
      initials = (json['avatar_initials'] ?? json['avatarInitials']).toString();
    } else if (rawName.isNotEmpty) {
      final parts = rawName.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    return UserProfile(
      id: json['id']?.toString() ?? 'user_default',
      name: rawName,
      email: json['email'] as String? ?? 'student@linkup.dev',
      role: json['role']?.toString() ?? 'USER',
      college: json['college'] as String? ?? 'KPR Institute of Engineering and Technology',
      branch: rawBranch,
      year: json['year'] as String? ?? 'Year 3',
      bio: json['bio'] as String? ?? '',
      avatarInitials: initials,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      savedOpportunityIds: (json['saved_opportunities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['saved_opportunity_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['savedOpportunityIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      savedPostIds: (json['saved_posts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['saved_post_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['savedPostIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      joinedGroupIds: (json['joined_group_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['joinedGroupIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      connectedUserIds: (json['connected_user_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['connectedUserIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      pendingConnectionIds: (json['pending_connection_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['pendingConnectionIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      requestedMentorIds: (json['requested_mentor_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['requestedMentorIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      isOnboarded: json['is_onboarded'] as bool? ?? json['isOnboarded'] as bool? ?? false,
      createdAt: parsedDate,
    );
  }
}
