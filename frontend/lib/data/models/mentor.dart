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
    this.createdAt,
  });

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

    return Mentor(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Knowledge Mentor',
      role: json['role'] as String? ?? 'Mentor',
      college: json['college'] as String? ?? 'Engineering College',
      experience: json['experience'] as String? ?? '2+ Years',
      badge: json['badge'] as String? ?? 'Mentor',
      about: json['about'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      topics: (json['topics'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sessions: parsedSessions,
      isRequestedByCurrentUser: json['is_requested_by_current_user'] as bool? ?? json['isRequestedByCurrentUser'] as bool? ?? false,
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
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
