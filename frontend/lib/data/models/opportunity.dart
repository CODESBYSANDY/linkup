/// Opportunity model for hackathons, internships, jobs, workshops, etc.
/// Synchronized with FastAPI OpportunityResponse schema.
class Opportunity {
  final String id;
  final String title;
  final String organization;
  final String category; // Hackathon, Internship, Job, Competition, Workshop, Event
  final String? categoryId;
  final String domain; // Cybersecurity, AI / ML, Cloud, Web Development, etc.
  final String description;
  final String eligibility;
  final List<String> skills;
  final String location;
  final String mode; // ONLINE, OFFLINE, HYBRID
  final String prize;
  final String? salary;
  final String deadline;
  final String source;
  final String? sourceId;
  final String registrationUrl;
  final String? imageUrl;
  final String status;
  final bool isFeatured;
  final bool isSavedByCurrentUser;
  final bool isClosingSoon;
  final int daysLeft;
  final DateTime? createdAt;

  const Opportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.category,
    this.categoryId,
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
    this.sourceId,
    required this.registrationUrl,
    this.imageUrl,
    this.status = 'ACTIVE',
    this.isFeatured = false,
    this.isSavedByCurrentUser = false,
    this.isClosingSoon = false,
    this.daysLeft = 14,
    this.createdAt,
  });

  Opportunity copyWith({
    String? id,
    String? title,
    String? organization,
    String? category,
    String? categoryId,
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
    String? sourceId,
    String? registrationUrl,
    String? imageUrl,
    String? status,
    bool? isFeatured,
    bool? isSavedByCurrentUser,
    bool? isClosingSoon,
    int? daysLeft,
    DateTime? createdAt,
  }) {
    return Opportunity(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
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
      sourceId: sourceId ?? this.sourceId,
      registrationUrl: registrationUrl ?? this.registrationUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      isSavedByCurrentUser: isSavedByCurrentUser ?? this.isSavedByCurrentUser,
      isClosingSoon: isClosingSoon ?? this.isClosingSoon,
      daysLeft: daysLeft ?? this.daysLeft,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    String deadlineStr = 'Open';
    if (json['deadline'] != null) {
      final raw = json['deadline'].toString();
      try {
        final parsed = DateTime.parse(raw);
        deadlineStr = '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
      } catch (_) {
        deadlineStr = raw.split('T').first;
      }
    }

    DateTime? createdAtParsed;
    if (json['created_at'] != null || json['createdAt'] != null) {
      try {
        createdAtParsed = DateTime.parse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '');
      } catch (_) {}
    }

    return Opportunity(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      category: json['category'] as String? ?? 'Hackathons',
      categoryId: json['category_id'] as String? ?? json['categoryId'] as String?,
      domain: json['domain'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      eligibility: json['eligibility'] as String? ?? 'All college students',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      location: json['location'] as String? ?? 'Online',
      mode: json['mode'] as String? ?? 'Online',
      prize: json['prize'] as String? ?? 'Opportunity',
      salary: json['salary'] as String?,
      deadline: deadlineStr,
      source: json['source'] as String? ?? 'LinkUp',
      sourceId: json['source_id'] as String? ?? json['sourceId'] as String?,
      registrationUrl: json['registration_url'] as String? ?? json['registrationUrl'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      isFeatured: json['is_featured'] as bool? ?? json['isFeatured'] as bool? ?? false,
      isSavedByCurrentUser: json['is_saved_by_current_user'] as bool? ?? json['isSavedByCurrentUser'] as bool? ?? false,
      isClosingSoon: json['is_closing_soon'] as bool? ?? json['isClosingSoon'] as bool? ?? false,
      daysLeft: json['days_left'] as int? ?? json['daysLeft'] as int? ?? 14,
      createdAt: createdAtParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organization': organization,
      'category': category,
      'category_id': categoryId,
      'domain': domain,
      'description': description,
      'eligibility': eligibility,
      'skills': skills,
      'location': location,
      'mode': mode,
      'prize': prize,
      'salary': salary,
      'deadline': deadline,
      'source': source,
      'source_id': sourceId,
      'registration_url': registrationUrl,
      'image_url': imageUrl,
      'status': status,
      'is_featured': isFeatured,
      'is_saved_by_current_user': isSavedByCurrentUser,
      'is_closing_soon': isClosingSoon,
      'days_left': daysLeft,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
