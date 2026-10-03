import 'package:flutter/foundation.dart';
import '../../core/services/api_client.dart';
import '../models/post.dart';
import '../models/comment.dart';

/// Repository managing community posts from FastAPI / PostgreSQL backend.
class CommunityRepository {
  final ValueNotifier<List<Post>> _postsNotifier = ValueNotifier<List<Post>>([]);
  final ValueNotifier<List<Post>> _savedPostsNotifier = ValueNotifier<List<Post>>([]);
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNext = false;

  ValueListenable<List<Post>> get postsNotifier => _postsNotifier;
  ValueListenable<List<Post>> get savedPostsNotifier => _savedPostsNotifier;
  List<Post> get allPosts => _postsNotifier.value;
  bool get isLoading => _isLoading;
  bool get hasNextPage => _hasNext;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  CommunityRepository() {
    fetchPosts();
    fetchSavedPosts();
  }

  /// Fetches real community posts from FastAPI with type, tag, group, and query filters.
  Future<void> fetchPosts({
    String query = '',
    PostType? type,
    String? tag,
    String? groupId,
    int page = 1,
    int limit = 20,
    bool isRefresh = false,
  }) async {
    _isLoading = true;
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (query.isNotEmpty) queryParams['search'] = query;
      if (type != null) queryParams['type'] = type.name;
      if (tag != null && tag != 'All' && tag.isNotEmpty) queryParams['tag'] = tag;
      if (groupId != null && groupId.isNotEmpty) queryParams['group_id'] = groupId;

      final response = await ApiClient.instance.get('posts', queryParams: queryParams);
      if (response is Map && response['items'] is List) {
        final items = (response['items'] as List)
            .map((json) => Post.fromJson(json as Map<String, dynamic>))
            .toList();

        _currentPage = response['page'] as int? ?? page;
        _totalPages = response['total_pages'] as int? ?? 1;
        _hasNext = response['has_next'] as bool? ?? false;

        if (page == 1 || isRefresh) {
          _postsNotifier.value = items;
        } else {
          _postsNotifier.value = [..._postsNotifier.value, ...items];
        }
      }
    } catch (e) {
      debugPrint('[CommunityRepository] Backend fetch notice: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Fetches saved posts from GET /api/v1/me/saved-posts.
  Future<void> fetchSavedPosts() async {
    try {
      final response = await ApiClient.instance.get('me/saved-posts');
      if (response is Map && response['items'] is List) {
        final items = (response['items'] as List)
            .map((json) => Post.fromJson(json as Map<String, dynamic>))
            .toList();
        _savedPostsNotifier.value = items;
      }
    } catch (e) {
      debugPrint('[CommunityRepository] Saved posts sync notice: $e');
    }
  }

  /// Creates a new post via backend API (author derived securely by backend).
  Future<bool> addPost(Post newPost) async {
    // Optimistic UI update
    _postsNotifier.value = [newPost, ..._postsNotifier.value];

    try {
      final payload = {
        'type': newPost.type.name,
        'title': newPost.title,
        'content': newPost.content,
        'tags': newPost.tags,
        if (newPost.groupId != null) 'group_id': newPost.groupId,
        if (newPost.externalUrl != null) 'external_url': newPost.externalUrl,
        if (newPost.imageUrl != null) 'image_url': newPost.imageUrl,
      };

      final response = await ApiClient.instance.post('posts', body: payload);
      if (response is Map<String, dynamic>) {
        final created = Post.fromJson(response);
        final current = List<Post>.from(_postsNotifier.value);
        final idx = current.indexWhere((p) => p.id == newPost.id);
        if (idx != -1) {
          current[idx] = created;
          _postsNotifier.value = current;
        }
        return true;
      }
    } catch (e) {
      debugPrint('[CommunityRepository] Error adding post to backend: $e');
    }
    return false;
  }

  /// Updates an existing post via PATCH /api/v1/posts/{id}.
  Future<bool> updatePost(String postId, {String? title, String? content, List<String>? tags}) async {
    try {
      final payload = <String, dynamic>{
        'title': ?title,
        'content': ?content,
        'tags': ?tags,
      };

      final response = await ApiClient.instance.patch('posts/$postId', body: payload);
      if (response is Map<String, dynamic>) {
        final updated = Post.fromJson(response);
        final currentList = List<Post>.from(_postsNotifier.value);
        final index = currentList.indexWhere((p) => p.id == postId);
        if (index != -1) {
          currentList[index] = updated;
          _postsNotifier.value = currentList;
        }
        return true;
      }
    } catch (e) {
      debugPrint('[CommunityRepository] Update post error: $e');
    }
    return false;
  }

  /// Deletes a post via DELETE /api/v1/posts/{id}.
  Future<bool> deletePost(String postId) async {
    // Optimistic delete
    final currentList = List<Post>.from(_postsNotifier.value);
    _postsNotifier.value = currentList.where((p) => p.id != postId).toList();

    try {
      await ApiClient.instance.delete('posts/$postId');
      return true;
    } catch (e) {
      debugPrint('[CommunityRepository] Delete post error: $e');
      _postsNotifier.value = currentList; // rollback
      return false;
    }
  }

  /// Toggles like on a post with optimistic UI and server synchronization.
  Future<void> toggleLikePost(String postId, String currentUserId) async {
    final currentList = List<Post>.from(_postsNotifier.value);
    final index = currentList.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = currentList[index];
    final likedIds = List<String>.from(post.likedUserIds);
    final isCurrentlyLiked = post.isLikedBy(currentUserId);

    if (isCurrentlyLiked) {
      likedIds.remove(currentUserId);
    } else {
      likedIds.add(currentUserId);
    }

    currentList[index] = post.copyWith(
      likedUserIds: likedIds,
      likesCount: isCurrentlyLiked ? (post.likesCount - 1).clamp(0, 999999) : post.likesCount + 1,
      isLikedByCurrentUser: !isCurrentlyLiked,
    );
    _postsNotifier.value = currentList;

    try {
      final response = await ApiClient.instance.post('posts/$postId/like');
      if (response is Map && response['likes_count'] != null) {
        final serverLikes = response['likes_count'] as int;
        final serverIsLiked = response['is_liked'] as bool? ?? !isCurrentlyLiked;
        final latestList = List<Post>.from(_postsNotifier.value);
        final latestIndex = latestList.indexWhere((p) => p.id == postId);
        if (latestIndex != -1) {
          latestList[latestIndex] = latestList[latestIndex].copyWith(
            likesCount: serverLikes,
            isLikedByCurrentUser: serverIsLiked,
          );
          _postsNotifier.value = latestList;
        }
      }
    } catch (e) {
      debugPrint('[CommunityRepository] Like toggle sync notice: $e');
    }
  }

  /// Adds a comment to a post with server synchronization.
  Future<void> addComment(String postId, Comment comment) async {
    final currentList = List<Post>.from(_postsNotifier.value);
    final index = currentList.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = currentList[index];
    final comments = List<Comment>.from(post.comments)..add(comment);
    currentList[index] = post.copyWith(
      comments: comments,
      commentsCount: post.commentsCount + 1,
    );
    _postsNotifier.value = currentList;

    try {
      final payload = {'content': comment.content};
      final response = await ApiClient.instance.post('posts/$postId/comments', body: payload);
      if (response is Map<String, dynamic>) {
        final createdComment = Comment.fromJson(response);
        final latestList = List<Post>.from(_postsNotifier.value);
        final latestIndex = latestList.indexWhere((p) => p.id == postId);
        if (latestIndex != -1) {
          final updatedComments = List<Comment>.from(latestList[latestIndex].comments)
            ..removeLast()
            ..add(createdComment);
          latestList[latestIndex] = latestList[latestIndex].copyWith(comments: updatedComments);
          _postsNotifier.value = latestList;
        }
      }
    } catch (e) {
      debugPrint('[CommunityRepository] Add comment sync notice: $e');
    }
  }

  /// Deletes a comment from a post.
  Future<bool> deleteComment(String postId, String commentId) async {
    final currentList = List<Post>.from(_postsNotifier.value);
    final index = currentList.indexWhere((p) => p.id == postId);
    if (index == -1) return false;

    final post = currentList[index];
    final comments = post.comments.where((c) => c.id != commentId).toList();
    currentList[index] = post.copyWith(
      comments: comments,
      commentsCount: (post.commentsCount - 1).clamp(0, 999999),
    );
    _postsNotifier.value = currentList;

    try {
      await ApiClient.instance.delete('comments/$commentId');
      return true;
    } catch (e) {
      debugPrint('[CommunityRepository] Delete comment error: $e');
      return false;
    }
  }

  /// Submits a moderation report against a post, comment, or user via POST /api/v1/reports.
  Future<bool> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) async {
    try {
      final payload = {
        'target_type': targetType,
        'target_id': targetId,
        'reason': reason,
        if (description != null && description.isNotEmpty) 'description': description,
      };
      await ApiClient.instance.post('reports', body: payload);
      return true;
    } catch (e) {
      debugPrint('[CommunityRepository] Report submission error: $e');
      return false;
    }
  }

  Post? getById(String id) {
    try {
      return _postsNotifier.value.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Post> filterPosts({String query = '', PostType? type, String? tag, String? groupId}) {
    return _postsNotifier.value.where((p) {
      if (groupId != null && p.groupId != groupId) return false;
      if (type != null && p.type != type) return false;
      if (tag != null && tag != 'All' && !p.tags.any((t) => t.toLowerCase() == tag.toLowerCase())) {
        return false;
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matches = p.title.toLowerCase().contains(q) ||
            p.content.toLowerCase().contains(q) ||
            p.authorName.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  /// Resets user-specific saved posts and state on logout.
  void reset() {
    _savedPostsNotifier.value = [];
    _postsNotifier.value = [];
  }
}
