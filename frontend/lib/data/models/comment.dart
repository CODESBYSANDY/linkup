/// Model representing a student comment on a post or question, synchronized with FastAPI CommentResponse.
class Comment {
  final String id;
  final String? postId;
  final String? authorId;
  final String authorName;
  final String authorRole;
  final String authorAvatar;
  final String content;
  final String timeAgo;
  final DateTime? createdAt;

  const Comment({
    required this.id,
    this.postId,
    this.authorId,
    required this.authorName,
    this.authorRole = 'Student',
    this.authorAvatar = 'SU',
    required this.content,
    required this.timeAgo,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null || json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '');
      } catch (_) {}
    }

    return Comment(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? json['postId']?.toString(),
      authorId: json['author_id']?.toString() ?? json['authorId']?.toString(),
      authorName: json['author_name'] as String? ?? json['authorName'] as String? ?? 'Student',
      authorRole: json['author_role'] as String? ?? json['authorRole'] as String? ?? 'Student',
      authorAvatar: json['author_avatar'] as String? ?? json['authorAvatar'] as String? ?? 'SU',
      content: json['content'] as String? ?? '',
      timeAgo: json['time_ago'] as String? ?? json['timeAgo'] as String? ?? 'just now',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': authorId,
      'author_name': authorName,
      'author_role': authorRole,
      'author_avatar': authorAvatar,
      'content': content,
      'time_ago': timeAgo,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
