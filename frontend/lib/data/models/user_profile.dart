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
    this.college = 'KPR Institute of Engineering and Technology',
    this.branch = 'Computer Science & Engineering',
    this.year = 'Year 3',
    this.bio = 'Passionate student developer exploring cybersecurity, AI/ML, and cloud systems.',
    this.avatarInitials = 'SB',
    this.avatarUrl,
    this.skills = const ['Cybersecurity', 'Flutter', 'Python', 'Networking', 'Git'],
    this.interests = const ['Cybersecurity', 'AI / ML', 'Software Development', 'Hackathons'],
    this.savedOpportunityIds = const ['opp_1', 'opp_3'],
    this.savedPostIds = const ['post_1'],
    this.joinedGroupIds = const ['group_1', 'group_2'],
    this.connectedUserIds = const ['user_2'],
    this.pendingConnectionIds = const ['user_3'],
    this.requestedMentorIds = const [],
    this.isOnboarded = true,
    this.createdAt,
  });

  /// Default demo user profile for quick login / guest access.
  factory UserProfile.defaultDemo() {
    return UserProfile(
      id: 'demo_user_1',
      name: 'Sandeep B',
      email: 'sandeep@student.linkup.dev',
      role: 'USER',
      college: 'KPR Institute of Engineering and Technology',
      branch: 'Computer Science & Engineering',
      year: 'Year 3',
      bio: 'Passionate student developer exploring cybersecurity, AI/ML, and cloud systems. Always open for hackathon collaborations.',
      avatarInitials: 'SB',
      skills: const ['Cybersecurity', 'Flutter', 'Python', 'Linux', 'Networking', 'Git'],
      interests: const ['Cybersecurity', 'AI / ML', 'Software Development', 'Hackathons', 'Cloud'],
      savedOpportunityIds: const ['opp_1', 'opp_2'],
      savedPostIds: const ['post_1', 'post_3'],
      joinedGroupIds: const ['grp_1', 'grp_2'],
      connectedUserIds: const ['peer_1'],
      pendingConnectionIds: const ['peer_2'],
      requestedMentorIds: const ['mentor_1'],
      isOnboarded: true,
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
