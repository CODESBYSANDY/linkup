/// Model representing a student comment on a post or question.
class Comment {
  final String id;
  final String authorName;
  final String authorRole;
  final String authorAvatar;
  final String content;
  final String timeAgo;

  const Comment({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatar,
    required this.content,
    required this.timeAgo,
  });
}
