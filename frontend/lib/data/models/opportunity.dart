/// Opportunity model for hackathons, internships, jobs, workshops, etc.
class Opportunity {
  final String id;
  final String title;
  final String organization;
  final String category; // Hackathon, Internship, Job, Competition, Workshop, Event
  final String domain; // Cybersecurity, AI / ML, Cloud, Web Development, etc.
  final String description;
  final String eligibility;
  final List<String> skills;
  final String location;
  final String mode; // Online, Hybrid, In-person
  final String prize;
  final String? salary;
  final String deadline;
  final String source;
  final String registrationUrl;
  final bool isFeatured;
  final bool isClosingSoon;
  final int daysLeft;

  const Opportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.category,
    required this.domain,
    required this.description,
    required this.eligibility,
    required this.skills,
    required this.location,
    required this.mode,
    required this.prize,
    this.salary,
    required this.deadline,
    required this.source,
    required this.registrationUrl,
    this.isFeatured = false,
    this.isClosingSoon = false,
    this.daysLeft = 14,
  });

  Opportunity copyWith({
    String? id,
    String? title,
    String? organization,
    String? category,
    String? domain,
    String? description,
    String? eligibility,
    List<String>? skills,
    String? location,
    String? mode,
    String? prize,
    String? salary,
    String? deadline,
    String? source,
    String? registrationUrl,
    bool? isFeatured,
    bool? isClosingSoon,
    int? daysLeft,
  }) {
    return Opportunity(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      category: category ?? this.category,
      domain: domain ?? this.domain,
      description: description ?? this.description,
      eligibility: eligibility ?? this.eligibility,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      mode: mode ?? this.mode,
      prize: prize ?? this.prize,
      salary: salary ?? this.salary,
      deadline: deadline ?? this.deadline,
      source: source ?? this.source,
      registrationUrl: registrationUrl ?? this.registrationUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      isClosingSoon: isClosingSoon ?? this.isClosingSoon,
      daysLeft: daysLeft ?? this.daysLeft,
    );
  }
}
