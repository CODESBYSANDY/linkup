/// Model representing a student or peer in the discovery network.
class Person {
  final String id;
  final String name;
  final String college;
  final String branch;
  final String year;
  final String role;
  final String bio;
  final String avatarInitials;
  final List<String> skills;
  final List<String> interests;
  final int mutualCount;
  final bool isMentor;

  const Person({
    required this.id,
    required this.name,
    required this.college,
    required this.branch,
    required this.year,
    required this.role,
    required this.bio,
    required this.avatarInitials,
    required this.skills,
    required this.interests,
    required this.mutualCount,
    this.isMentor = false,
  });
}
