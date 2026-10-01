import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/comment.dart';

/// Repository managing community posts, creation, local likes, and comments.
class CommunityRepository {
  final ValueNotifier<List<Post>> _postsNotifier = ValueNotifier<List<Post>>([]);

  ValueListenable<List<Post>> get postsNotifier => _postsNotifier;
  List<Post> get allPosts => _postsNotifier.value;

  CommunityRepository() {
    _initDummyPosts();
  }

  void _initDummyPosts() {
    _postsNotifier.value = [
      const Post(
        id: 'post_1',
        authorId: 'usr_arun',
        authorName: 'Arun Kumar',
        authorRole: 'Cybersecurity & CTF',
        authorYear: 'Year 3',
        authorAvatar: 'AK',
        type: PostType.question,
        title: 'How should I start learning Computer Networks for CTF challenges?',
        content: 'I have good fundamentals in Python and Linux CLI, but struggle with packet analysis and network protocols during Wireshark challenges. Any curated roadmaps, cheat sheets, or practice labs recommended?',
        tags: ['Networking', 'Cybersecurity', 'CTF', 'Wireshark'],
        likedUserIds: ['demo_user_1', 'user_2', 'user_3', 'user_4'],
        timeAgo: '2h ago',
        comments: [
          Comment(
            id: 'c_1',
            authorName: 'Rahul Sharma',
            authorRole: 'Knowledge Mentor',
            authorAvatar: 'RS',
            content: 'Start with "Practical Packet Analysis" by Chris Sanders. Also, solve the Wireshark challenges on CyberDefenders and TryHackMe Network room.',
            timeAgo: '1h ago',
          ),
          Comment(
            id: 'c_2',
            authorName: 'Sahana M',
            authorRole: 'Year 4 · CS',
            authorAvatar: 'SM',
            content: 'Check out Professor Messer\'s Network+ playlist for intuitive protocol visual breakdowns!',
            timeAgo: '35m ago',
          ),
        ],
      ),
      const Post(
        id: 'post_2',
        authorId: 'usr_ananya',
        authorName: 'Ananya Sharma',
        authorRole: 'AI & Data Science',
        authorYear: 'Year 3',
        authorAvatar: 'AS',
        type: PostType.project,
        title: 'Built an open-source Rust-based packet visualizer for students',
        content: 'Hey everyone! I just published my semester project — a lightweight network traffic visualizer written in Rust + Flutter. It graphs TCP streams in real-time with sub-millisecond parsing overhead. Would love feedback, code reviews, and student contributors!',
        tags: ['Rust', 'Flutter', 'OpenSource', 'Networking'],
        likedUserIds: ['user_2', 'user_5', 'user_6'],
        timeAgo: '5h ago',
        comments: [
          Comment(
            id: 'c_3',
            authorName: 'Sandeep B',
            authorRole: 'Year 3 · Student Developer',
            authorAvatar: 'SB',
            content: 'Super clean architecture! How did you bridge the Rust FFI bindings to Flutter streams?',
            timeAgo: '3h ago',
          ),
        ],
      ),
      const Post(
        id: 'post_3',
        authorId: 'usr_deepak',
        authorName: 'Deepak V',
        authorRole: 'Cloud & DevOps',
        authorYear: 'Year 4',
        authorAvatar: 'DV',
        type: PostType.resource,
        title: 'Curated list of 100% Free Cloud & Kubernetes practice sandboxes for 2026',
        content: 'Here is a breakdown of free compute tiers, interactive browser terminals (Killercoda, Katacoda alternatives), and student vouchers from GitHub Student Developer Pack that do not require credit cards.\n\n1. Killercoda (Free interactive CKA/CKAD scenarios)\n2. Google Cloud Skills Boost 30-day student pass\n3. Oracle Cloud Free Tier (4 ARM cores + 24GB RAM for lifetime)\n4. Okteto Free Dev Spaces for Kubernetes',
        tags: ['Cloud', 'Kubernetes', 'DevOps', 'FreeResources'],
        likedUserIds: ['demo_user_1', 'user_7', 'user_8', 'user_9'],
        timeAgo: '1d ago',
        comments: [],
      ),
      const Post(
        id: 'post_4',
        authorId: 'usr_priya',
        authorName: 'Priya R',
        authorRole: 'Full Stack & Web3',
        authorYear: 'Year 2',
        authorAvatar: 'PR',
        type: PostType.knowledge,
        title: 'Understanding Database Indexing: B-Trees vs LSM-Trees in 5 minutes',
        content: 'Traditional relational databases like PostgreSQL use B+ Trees for fast random point-lookups and range queries, whereas modern write-heavy databases like Cassandra and RocksDB use Log-Structured Merge (LSM) trees to optimize write throughput by appending sequentially.',
        tags: ['Database', 'PostgreSQL', 'SystemDesign', 'Storage'],
        likedUserIds: ['user_1', 'user_3'],
        timeAgo: '1d ago',
        comments: [],
      ),
      const Post(
        id: 'post_5',
        authorId: 'usr_karthik',
        authorName: 'Karthik Raja',
        authorRole: 'Competitive Programming',
        authorYear: 'Year 3',
        authorAvatar: 'KR',
        type: PostType.discussion,
        title: 'Is C++ still the unbeatable king for CP or is Rust ready for contests?',
        content: 'C++ with STL algorithms (`std::sort`, `std::priority_queue`) is super fast to write under time pressure. Has anyone here switched to Rust for Codeforces or LeetCode? How do you deal with tricky graph lifetimes during timed rounds?',
        tags: ['CompetitiveProgramming', 'Cpp', 'Rust', 'Algorithms'],
        likedUserIds: ['user_4', 'user_6'],
        timeAgo: '2d ago',
        comments: [],
      ),
      const Post(
        id: 'post_6',
        authorId: 'usr_sahana',
        authorName: 'Sahana M',
        authorRole: 'AI Research',
        authorYear: 'Year 4',
        authorAvatar: 'SM',
        type: PostType.knowledge,
        title: 'Key takeaways from the latest Multimodal Mixture-of-Experts (MoE) paper',
        content: 'Sparse Mixture of Experts allows scaling model capacity without proportionally increasing inference FLOPs. Only top-k expert sub-networks are activated per token routed by a gating network.',
        tags: ['AI', 'MachineLearning', 'Research', 'LLMs'],
        likedUserIds: ['user_2', 'user_8'],
        timeAgo: '3d ago',
        comments: [],
      ),
      const Post(
        id: 'post_7',
        authorId: 'usr_vikram',
        authorName: 'Vikram S',
        authorRole: 'IoT & Robotics',
        authorYear: 'Year 3',
        authorAvatar: 'VS',
        type: PostType.project,
        title: 'ESP32 Smart Campus Environmental Telemetry Monitor',
        content: 'Deployed 12 low-power ESP32 sensor nodes across our college campus communicating via ESP-NOW to a central Raspberry Pi gateway with Grafana dashboard.',
        tags: ['IoT', 'ESP32', 'Embedded', 'Sensors'],
        likedUserIds: ['user_1', 'user_5'],
        timeAgo: '3d ago',
        comments: [],
      ),
      const Post(
        id: 'post_8',
        authorId: 'usr_meera',
        authorName: 'Meera N',
        authorRole: 'Cybersecurity Research',
        authorYear: 'Year 4',
        authorAvatar: 'MN',
        type: PostType.question,
        title: 'Recommended resources for binary exploitation and buffer overflow labs?',
        content: 'I am comfortable with basic GDB and assembly syntax. Looking for hands-on challenges to practice ROP chains, ASLR bypass, and ret2libc on modern Linux kernels.',
        tags: ['Cybersecurity', 'BinaryExploitation', 'GDB', 'ReverseEng'],
        likedUserIds: ['user_3', 'user_7'],
        timeAgo: '4d ago',
        comments: [],
      ),
      const Post(
        id: 'post_9',
        authorId: 'usr_nathan',
        authorName: 'Nathan Cole',
        authorRole: 'Mobile Architecture',
        authorYear: 'Year 3',
        authorAvatar: 'NC',
        type: PostType.resource,
        title: 'Clean Architecture in Flutter: Practical Guide with Zero Boilerplate',
        content: 'A comprehensive repository template demonstrating how to structure domain entities, repositories, and state-agnostic presentation layers cleanly.',
        tags: ['Flutter', 'CleanArchitecture', 'MobileDev', 'Dart'],
        likedUserIds: ['demo_user_1', 'user_2'],
        timeAgo: '5d ago',
        comments: [],
      ),
      const Post(
        id: 'post_10',
        authorId: 'usr_rohit',
        authorName: 'Rohit K',
        authorRole: 'DevOps & SRE',
        authorYear: 'Year 2',
        authorAvatar: 'RK',
        type: PostType.discussion,
        title: 'Building a student homelab: Raspberry Pi cluster vs Old ThinkPad laptop?',
        content: 'Looking to set up a 24/7 home lab for self-hosting GitLab, Docker containers, and Nextcloud. What is your go-to hardware recommendation on a student budget?',
        tags: ['HomeLab', 'Linux', 'SelfHosted', 'DevOps'],
        likedUserIds: ['user_6', 'user_9'],
        timeAgo: '6d ago',
        comments: [],
      ),
    ];
  }

  void addPost(Post newPost) {
    _postsNotifier.value = [newPost, ..._postsNotifier.value];
  }

  void toggleLikePost(String postId, String currentUserId) {
    final currentList = List<Post>.from(_postsNotifier.value);
    final index = currentList.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = currentList[index];
    final likedIds = List<String>.from(post.likedUserIds);
    if (likedIds.contains(currentUserId)) {
      likedIds.remove(currentUserId);
    } else {
      likedIds.add(currentUserId);
    }

    currentList[index] = post.copyWith(likedUserIds: likedIds);
    _postsNotifier.value = currentList;
  }

  void addComment(String postId, Comment comment) {
    final currentList = List<Post>.from(_postsNotifier.value);
    final index = currentList.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = currentList[index];
    final comments = List<Comment>.from(post.comments)..add(comment);
    currentList[index] = post.copyWith(comments: comments);
    _postsNotifier.value = currentList;
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
}
