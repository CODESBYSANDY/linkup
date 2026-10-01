/// Model representing an interest-based student technical group or community.
/// Synchronized with FastAPI GroupResponse schema.
class Group {
  final String id;
  final String name;
  final String category;
  final String description;
  final int membersCount;
  final String iconName; // e.g. 'security', 'ai', 'code', 'cloud', 'blockchain'
  final bool isJoinedByCurrentUser;
  final List<String> rules;
  final List<String> resources;
  final List<String> events;
  final DateTime? createdAt;

  const Group({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.membersCount,
    this.iconName = 'group',
    this.isJoinedByCurrentUser = false,
    this.rules = const [
      'Be respectful and collaborative.',
      'Share original code and provide attribution.',
      'Keep discussions technical and constructive.',
    ],
    this.resources = const [
      'Curated Learning Roadmap (Google Docs)',
      'GitHub Organization Repositories',
      'Weekly Practice Room Archive',
    ],
    this.events = const [
      'Weekend Collaborative Hack Session (Saturday 7 PM)',
      'Paper Reading & Architecture Breakdown (Wednesday 6 PM)',
    ],
    this.createdAt,
  });

  Group copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    int? membersCount,
    String? iconName,
    bool? isJoinedByCurrentUser,
    List<String>? rules,
    List<String>? resources,
    List<String>? events,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      membersCount: membersCount ?? this.membersCount,
      iconName: iconName ?? this.iconName,
      isJoinedByCurrentUser: isJoinedByCurrentUser ?? this.isJoinedByCurrentUser,
      rules: rules ?? this.rules,
      resources: resources ?? this.resources,
      events: events ?? this.events,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null || json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '');
      } catch (_) {}
    }

    final rawRules = json['rules'] as List<dynamic>?;
    final rawResources = json['resources'] as List<dynamic>?;
    final rawEvents = json['events'] as List<dynamic>?;

    return Group(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Technical Community',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      membersCount: json['members_count'] as int? ?? json['membersCount'] as int? ?? 12,
      iconName: json['icon_name'] as String? ?? json['iconName'] as String? ?? 'groups',
      isJoinedByCurrentUser: json['is_joined_by_current_user'] as bool? ?? json['isJoinedByCurrentUser'] as bool? ?? false,
      rules: rawRules != null
          ? rawRules.map((e) => e.toString()).toList()
          : const [
              'Be respectful and collaborative.',
              'Share verified technical resources.',
              'Keep discussions constructive.',
            ],
      resources: rawResources != null
          ? rawResources.map((e) => e.toString()).toList()
          : const [
              'Curated Learning Roadmap',
              'GitHub Organization Repositories',
            ],
      events: rawEvents != null
          ? rawEvents.map((e) => e.toString()).toList()
          : const [
              'Weekend Collaborative Hack Session (Saturday 7 PM)',
            ],
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'members_count': membersCount,
      'icon_name': iconName,
      'is_joined_by_current_user': isJoinedByCurrentUser,
      'rules': rules,
      'resources': resources,
      'events': events,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
