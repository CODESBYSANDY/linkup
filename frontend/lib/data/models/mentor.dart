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
}

/// Model representing an experienced student, researcher, or faculty mentor.
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
  });
}
