import 'comment.dart';

/// Post types supported in the student community.
enum PostType {
  knowledge,
  question,
  project,
  resource,
  opportunity,
  discussion,
}

extension PostTypeExtension on PostType {
  String get label {
    switch (this) {
      case PostType.knowledge:
        return 'KNOWLEDGE';
      case PostType.question:
        return 'QUESTION';
      case PostType.project:
        return 'PROJECT SHOWCASE';
      case PostType.resource:
        return 'RESOURCE';
      case PostType.opportunity:
        return 'OPPORTUNITY';
      case PostType.discussion:
        return 'DISCUSSION';
    }
  }

  String get displayName {
    switch (this) {
      case PostType.knowledge:
        return '💡 Knowledge';
      case PostType.question:
        return '❓ Question';
      case PostType.project:
        return '🚀 Project';
      case PostType.resource:
        return '📚 Resource';
      case PostType.opportunity:
        return '🏆 Opportunity';
      case PostType.discussion:
        return '💬 Discussion';
    }
  }
}

/// Model representing a student community post.
class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String authorYear;
  final String authorAvatar;
  final PostType type;
  final String title;
  final String content;
  final List<String> tags;
  final List<String> likedUserIds;
  final List<Comment> comments;
  final String timeAgo;
  final String? groupId;
  final String? groupName;
  final String? externalUrl;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.authorYear,
    required this.authorAvatar,
    required this.type,
    required this.title,
    required this.content,
    required this.tags,
    this.likedUserIds = const [],
    this.comments = const [],
    required this.timeAgo,
    this.groupId,
    this.groupName,
    this.externalUrl,
  });

  int get likesCount => likedUserIds.length;
  int get commentsCount => comments.length;

  bool isLikedBy(String userId) => likedUserIds.contains(userId);

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? authorYear,
    String? authorAvatar,
    PostType? type,
    String? title,
    String? content,
    List<String>? tags,
    List<String>? likedUserIds,
    List<Comment>? comments,
    String? timeAgo,
    String? groupId,
    String? groupName,
    String? externalUrl,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorYear: authorYear ?? this.authorYear,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      likedUserIds: likedUserIds ?? this.likedUserIds,
      comments: comments ?? this.comments,
      timeAgo: timeAgo ?? this.timeAgo,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      externalUrl: externalUrl ?? this.externalUrl,
    );
  }
}
