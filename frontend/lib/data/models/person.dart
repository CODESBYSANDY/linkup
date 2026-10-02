/// Model representing a student peer in the discovery network, synchronized with FastAPI UserPublicResponse.
class Person {
  final String id;
  final String name;
  final String college;
  final String branch;
  final String year;
  final String role;
  final String bio;
  final String avatarInitials;
  final String? avatarUrl;
  final List<String> skills;
  final List<String> interests;
  final int mutualCount;
  final bool isMentor;
  final String? connectionStatus; // None, "PENDING", "ACCEPTED", "connected", "pending"
  final DateTime? createdAt;

  const Person({
    required this.id,
    required this.name,
    required this.college,
    required this.branch,
    required this.year,
    this.role = 'Student',
    required this.bio,
    required this.avatarInitials,
    this.avatarUrl,
    required this.skills,
    required this.interests,
    this.mutualCount = 0,
    this.isMentor = false,
    this.connectionStatus,
    this.createdAt,
  });

  bool get isConnected => connectionStatus == 'connected' || connectionStatus == 'ACCEPTED';
  bool get isPending => connectionStatus == 'pending' || connectionStatus == 'PENDING';

  Person copyWith({
    String? id,
    String? name,
    String? college,
    String? branch,
    String? year,
    String? role,
    String? bio,
    String? avatarInitials,
    String? avatarUrl,
    List<String>? skills,
    List<String>? interests,
    int? mutualCount,
    bool? isMentor,
    String? connectionStatus,
    DateTime? createdAt,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      mutualCount: mutualCount ?? this.mutualCount,
      isMentor: isMentor ?? this.isMentor,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null || json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '');
      } catch (_) {}
    }

    final rawName = json['full_name'] as String? ?? json['name'] as String? ?? 'Student Peer';
    final branchStr = json['department'] as String? ?? json['branch'] as String? ?? 'Computer Science';
    final roleStr = '$branchStr · ${json['year'] ?? 'Student'}';

    String initials = 'SP';
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

    return Person(
      id: json['id']?.toString() ?? '',
      name: rawName,
      college: json['college'] as String? ?? 'KPR Institute of Engineering and Technology',
      branch: branchStr,
      year: json['year'] as String? ?? 'Year 3',
      role: roleStr,
      bio: json['bio'] as String? ?? '',
      avatarInitials: initials,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      mutualCount: json['mutual_count'] as int? ?? json['mutualCount'] as int? ?? 2,
      isMentor: json['is_mentor'] as bool? ?? json['isMentor'] as bool? ?? false,
      connectionStatus: json['connection_status'] as String? ?? json['connectionStatus'] as String?,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'college': college,
      'branch': branch,
      'year': year,
      'bio': bio,
      'avatar_initials': avatarInitials,
      'avatar_url': avatarUrl,
      'skills': skills,
      'interests': interests,
      'connection_status': connectionStatus,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
