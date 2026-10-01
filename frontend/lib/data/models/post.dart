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

  static PostType fromString(String? typeStr) {
    if (typeStr == null) return PostType.discussion;
    switch (typeStr.toLowerCase()) {
      case 'knowledge':
        return PostType.knowledge;
      case 'question':
        return PostType.question;
      case 'project':
        return PostType.project;
      case 'resource':
        return PostType.resource;
      case 'opportunity':
        return PostType.opportunity;
      case 'discussion':
      default:
        return PostType.discussion;
    }
  }
}

/// Model representing a student community post, synchronized with FastAPI PostResponse.
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
  final int likesCount;
  final int commentsCount;
  final bool isLikedByCurrentUser;
  final bool isSavedByCurrentUser;
  final String timeAgo;
  final String? groupId;
  final String? groupName;
  final String? externalUrl;
  final String? imageUrl;
  final DateTime? createdAt;

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
    int? likesCount,
    int? commentsCount,
    this.isLikedByCurrentUser = false,
    this.isSavedByCurrentUser = false,
    required this.timeAgo,
    this.groupId,
    this.groupName,
    this.externalUrl,
    this.imageUrl,
    this.createdAt,
  })  : likesCount = likesCount ?? likedUserIds.length,
        commentsCount = commentsCount ?? comments.length;

  int get upvotes => likesCount;

  bool isLikedBy(String userId) => isLikedByCurrentUser || likedUserIds.contains(userId);

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
    int? likesCount,
    int? commentsCount,
    bool? isLikedByCurrentUser,
    bool? isSavedByCurrentUser,
    String? timeAgo,
    String? groupId,
    String? groupName,
    String? externalUrl,
    String? imageUrl,
    DateTime? createdAt,
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
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isSavedByCurrentUser: isSavedByCurrentUser ?? this.isSavedByCurrentUser,
      timeAgo: timeAgo ?? this.timeAgo,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      externalUrl: externalUrl ?? this.externalUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final likedList = (json['liked_user_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        (json['likedUserIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];

    final commentList = (json['comments'] as List<dynamic>?)
            ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    DateTime? parsedDate;
    if (json['created_at'] != null || json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '');
      } catch (_) {}
    }

    final rawLikes = json['likes_count'] ?? json['likesCount'] ?? likedList.length;
    final rawComments = json['comments_count'] ?? json['commentsCount'] ?? commentList.length;

    String authorName = 'Student';
    if (json['author_name'] != null || json['authorName'] != null) {
      authorName = (json['author_name'] ?? json['authorName']).toString();
    } else if (json['author'] is Map) {
      final authorMap = json['author'] as Map;
      authorName = authorMap['full_name']?.toString() ?? authorMap['name']?.toString() ?? 'Student';
    }

    String authorAvatar = 'SU';
    if (json['author_avatar'] != null || json['authorAvatar'] != null) {
      authorAvatar = (json['author_avatar'] ?? json['authorAvatar']).toString();
    } else if (authorName.isNotEmpty && authorName != 'Student') {
      final parts = authorName.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        authorAvatar = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        authorAvatar = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    final isLiked = json['is_liked'] as bool? ??
        json['is_liked_by_current_user'] as bool? ??
        json['isLikedByCurrentUser'] as bool? ??
        false;

    return Post(
      id: json['id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? json['authorId']?.toString() ?? '',
      authorName: authorName,
      authorRole: json['author_role'] as String? ?? json['authorRole'] as String? ?? 'Student',
      authorYear: json['author_year'] as String? ?? json['authorYear'] as String? ?? 'Year 1',
      authorAvatar: authorAvatar,
      type: PostTypeExtension.fromString(json['type']?.toString()),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      likedUserIds: likedList,
      comments: commentList,
      likesCount: rawLikes is int ? rawLikes : int.tryParse(rawLikes.toString()) ?? likedList.length,
      commentsCount: rawComments is int ? rawComments : int.tryParse(rawComments.toString()) ?? commentList.length,
      isLikedByCurrentUser: isLiked,
      isSavedByCurrentUser: json['is_saved_by_current_user'] as bool? ?? json['isSavedByCurrentUser'] as bool? ?? false,
      timeAgo: json['time_ago'] as String? ?? json['timeAgo'] as String? ?? 'recently',
      groupId: json['group_id'] as String? ?? json['groupId'] as String?,
      groupName: json['group_name'] as String? ?? json['groupName'] as String?,
      externalUrl: json['external_url'] as String? ?? json['externalUrl'] as String?,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'author_name': authorName,
      'author_role': authorRole,
      'author_year': authorYear,
      'author_avatar': authorAvatar,
      'type': type.name,
      'title': title,
      'content': content,
      'tags': tags,
      'liked_user_ids': likedUserIds,
      'comments': comments.map((c) => c.toJson()).toList(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked_by_current_user': isLikedByCurrentUser,
      'is_saved_by_current_user': isSavedByCurrentUser,
      'time_ago': timeAgo,
      'group_id': groupId,
      'group_name': groupName,
      'external_url': externalUrl,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
