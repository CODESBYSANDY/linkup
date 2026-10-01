/// Model representing an interest-based student technical group or community.
class Group {
  final String id;
  final String name;
  final String category;
  final String description;
  final int membersCount;
  final String iconName; // e.g. 'security', 'ai', 'code', 'cloud', 'blockchain'
  final List<String> rules;
  final List<String> resources;
  final List<String> events;

  const Group({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.membersCount,
    required this.iconName,
    this.rules = const [
      'Be respectful and collaborative.',
      'Share original code and provide attribution.',
      'Keep discussions technical and constructive.',
    ],
    this.resources = const [
      'Curated Learning Roadmap (Google Docs)',
      'GitHub Organization Repositories',
      'Weekly CTF Practice Room Archive',
    ],
    this.events = const [
      'Weekend Collaborative Hack Session (Saturday 7 PM)',
      'Paper Reading & Architecture Breakdown (Wednesday 6 PM)',
    ],
  });

  Group copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    int? membersCount,
    String? iconName,
    List<String>? rules,
    List<String>? resources,
    List<String>? events,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      membersCount: membersCount ?? this.membersCount,
      iconName: iconName ?? this.iconName,
      rules: rules ?? this.rules,
      resources: resources ?? this.resources,
      events: events ?? this.events,
    );
  }
}
