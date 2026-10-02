/// Learning Session module for mentors.
class LearningSession {
  final String id;
  final String title;
  final String description;
  final String duration;

  const LearningSession({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
  });

  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Learning Module',
      description: json['description'] as String? ?? '',
      duration: json['duration'] as String? ?? '45 mins',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
    };
  }
}

/// Model representing an experienced student, researcher, or faculty mentor.
/// Synchronized with FastAPI MentorResponse schema.
class Mentor {
  final String id;
  final String name;
  final String role;
  final String college;
  final String experience;
  final String badge;
  final String about;
  final List<String> skills;
  final List<String> topics;
  final List<LearningSession> sessions;
  final bool isRequestedByCurrentUser;
  final bool isAvailable;
  final double rating;
  final int reviewsCount;
  final String? avatarUrl;
  final DateTime? createdAt;

  const Mentor({
    required this.id,
    required this.name,
    required this.role,
    required this.college,
    required this.experience,
    required this.badge,
    required this.about,
    required this.skills,
    required this.topics,
    required this.sessions,
    this.isRequestedByCurrentUser = false,
    this.isAvailable = true,
    this.rating = 4.9,
    this.reviewsCount = 18,
    this.avatarUrl,
    this.createdAt,
  });

  bool get hasRequested => isRequestedByCurrentUser;

  Mentor copyWith({
    String? id,
    String? name,
    String? role,
    String? college,
    String? experience,
    String? badge,
    String? about,
    List<String>? skills,
    List<String>? topics,
    List<LearningSession>? sessions,
    bool? isRequestedByCurrentUser,
    bool? hasRequested,
    bool? isAvailable,
    double? rating,
    int? reviewsCount,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return Mentor(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      college: college ?? this.college,
      experience: experience ?? this.experience,
      badge: badge ?? this.badge,
      about: about ?? this.about,
      skills: skills ?? this.skills,
      topics: topics ?? this.topics,
      sessions: sessions ?? this.sessions,
      isRequestedByCurrentUser: hasRequested ?? isRequestedByCurrentUser ?? this.isRequestedByCurrentUser,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Mentor.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null || json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '');
      } catch (_) {}
    }

    final rawSessions = json['sessions'] as List<dynamic>?;
    final parsedSessions = rawSessions != null
        ? rawSessions.map((s) {
            if (s is Map<String, dynamic>) return LearningSession.fromJson(s);
            if (s is Map) return LearningSession.fromJson(Map<String, dynamic>.from(s));
            return LearningSession(id: 'sess_1', title: s.toString(), description: '', duration: '45 mins');
          }).toList()
        : <LearningSession>[];

    final collegeOrOrg = json['company_or_institution'] as String? ??
        json['organization'] as String? ??
        json['college'] as String? ??
        'Engineering Institution';

    final expStr = json['experience_years'] != null
        ? '${json['experience_years']} Years Experience'
        : json['experience'] as String? ?? '2+ Years';

    final requested = json['has_requested'] as bool? ??
        json['is_requested_by_current_user'] as bool? ??
        json['isRequestedByCurrentUser'] as bool? ??
        false;

    return Mentor(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Knowledge Mentor',
      role: json['role'] as String? ?? 'Mentor',
      college: collegeOrOrg,
      experience: expStr,
      badge: json['badge'] as String? ?? 'Mentor',
      about: json['about'] as String? ?? json['bio'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['domains'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      topics: (json['topics'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sessions: parsedSessions,
      isRequestedByCurrentUser: requested,
      isAvailable: json['is_available'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: json['reviews_count'] as int? ?? 18,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'college': college,
      'experience': experience,
      'badge': badge,
      'about': about,
      'skills': skills,
      'topics': topics,
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'is_requested_by_current_user': isRequestedByCurrentUser,
      'is_available': isAvailable,
      'rating': rating,
      'reviews_count': reviewsCount,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
