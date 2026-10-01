/// Model representing a student user profile in LinkUp.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String college;
  final String branch;
  final String year;
  final String bio;
  final String avatarInitials;
  final List<String> skills;
  final List<String> interests;
  final List<String> savedOpportunityIds;
  final List<String> savedPostIds;
  final List<String> joinedGroupIds;
  final List<String> connectedUserIds;
  final List<String> pendingConnectionIds;
  final List<String> requestedMentorIds;
  final bool isOnboarded;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.college = 'KPR Institute of Engineering and Technology',
    this.branch = 'Computer Science & Engineering',
    this.year = 'Year 3',
    this.bio = 'Passionate student developer exploring cybersecurity, AI/ML, and cloud systems.',
    this.avatarInitials = 'SB',
    this.skills = const ['Cybersecurity', 'Flutter', 'Python', 'Networking', 'Git'],
    this.interests = const ['Cybersecurity', 'AI / ML', 'Software Development', 'Hackathons'],
    this.savedOpportunityIds = const ['opp_1', 'opp_3'],
    this.savedPostIds = const ['post_1'],
    this.joinedGroupIds = const ['group_1', 'group_2'],
    this.connectedUserIds = const ['user_2'],
    this.pendingConnectionIds = const ['user_3'],
    this.requestedMentorIds = const [],
    this.isOnboarded = true,
  });

  /// Default demo user profile for quick login / guest access.
  factory UserProfile.defaultDemo() {
    return const UserProfile(
      id: 'demo_user_1',
      name: 'Sandeep B',
      email: 'sandeep@student.linkup.dev',
      college: 'KPR Institute of Engineering and Technology',
      branch: 'Computer Science & Engineering',
      year: 'Year 3',
      bio: 'Passionate student developer exploring cybersecurity, AI/ML, and cloud systems. Always open for hackathon collaborations.',
      avatarInitials: 'SB',
      skills: ['Cybersecurity', 'Flutter', 'Python', 'Linux', 'Networking', 'Git'],
      interests: ['Cybersecurity', 'AI / ML', 'Software Development', 'Hackathons', 'Cloud'],
      savedOpportunityIds: ['opp_1', 'opp_2'],
      savedPostIds: ['post_1', 'post_3'],
      joinedGroupIds: ['grp_1', 'grp_2'],
      connectedUserIds: ['peer_1'],
      pendingConnectionIds: ['peer_2'],
      requestedMentorIds: ['mentor_1'],
      isOnboarded: true,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? college,
    String? branch,
    String? year,
    String? bio,
    String? avatarInitials,
    List<String>? skills,
    List<String>? interests,
    List<String>? savedOpportunityIds,
    List<String>? savedPostIds,
    List<String>? joinedGroupIds,
    List<String>? connectedUserIds,
    List<String>? pendingConnectionIds,
    List<String>? requestedMentorIds,
    bool? isOnboarded,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      bio: bio ?? this.bio,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      savedOpportunityIds: savedOpportunityIds ?? this.savedOpportunityIds,
      savedPostIds: savedPostIds ?? this.savedPostIds,
      joinedGroupIds: joinedGroupIds ?? this.joinedGroupIds,
      connectedUserIds: connectedUserIds ?? this.connectedUserIds,
      pendingConnectionIds: pendingConnectionIds ?? this.pendingConnectionIds,
      requestedMentorIds: requestedMentorIds ?? this.requestedMentorIds,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'college': college,
      'branch': branch,
      'year': year,
      'bio': bio,
      'avatarInitials': avatarInitials,
      'skills': skills,
      'interests': interests,
      'savedOpportunityIds': savedOpportunityIds,
      'savedPostIds': savedPostIds,
      'joinedGroupIds': joinedGroupIds,
      'connectedUserIds': connectedUserIds,
      'pendingConnectionIds': pendingConnectionIds,
      'requestedMentorIds': requestedMentorIds,
      'isOnboarded': isOnboarded,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'user_default',
      name: json['name'] as String? ?? 'Student User',
      email: json['email'] as String? ?? 'student@linkup.dev',
      college: json['college'] as String? ?? 'Engineering College',
      branch: json['branch'] as String? ?? 'Computer Science',
      year: json['year'] as String? ?? 'Year 3',
      bio: json['bio'] as String? ?? '',
      avatarInitials: json['avatarInitials'] as String? ?? 'SU',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      savedOpportunityIds: (json['savedOpportunityIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      savedPostIds: (json['savedPostIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      joinedGroupIds: (json['joinedGroupIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      connectedUserIds: (json['connectedUserIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      pendingConnectionIds: (json['pendingConnectionIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      requestedMentorIds: (json['requestedMentorIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isOnboarded: json['isOnboarded'] as bool? ?? true,
    );
  }
}
