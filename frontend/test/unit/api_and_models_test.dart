import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/config/app_config.dart';
import 'package:linkup/core/network/api_exceptions.dart';
import 'package:linkup/core/services/api_client.dart';
import 'package:linkup/data/models/opportunity.dart';
import 'package:linkup/data/models/post.dart';
import 'package:linkup/data/models/comment.dart';
import 'package:linkup/data/models/user_profile.dart';
import 'package:linkup/data/models/person.dart';
import 'package:linkup/data/models/group.dart';
import 'package:linkup/data/models/mentor.dart';
import 'package:linkup/data/models/notification_item.dart';

void main() {
  group('AppConfig & Environment Tests', () {
    test('apiBaseUrl defaults to valid URL without trailing slash', () {
      expect(AppConfig.apiBaseUrl, isNotEmpty);
      expect(AppConfig.apiBaseUrl.endsWith('/'), isFalse);
    });

    test('isProduction flag evaluation', () {
      expect(AppConfig.isProduction, isA<bool>());
    });
  });

  group('ApiException Tests', () {
    test('fromStatusCode maps HTTP errors to clear user-friendly messages', () {
      final badRequest = ApiException.fromStatusCode(400);
      expect(badRequest.message, contains('Invalid request'));
      expect(badRequest.statusCode, equals(400));

      final unauthorized = ApiException.fromStatusCode(401);
      expect(unauthorized.message, contains('session has expired'));

      final forbidden = ApiException.fromStatusCode(403);
      expect(forbidden.message, contains('permission'));

      final notFound = ApiException.fromStatusCode(404);
      expect(notFound.message, contains('not be found'));

      final conflict = ApiException.fromStatusCode(409);
      expect(conflict.message, contains('already been performed'));

      final unprocessable = ApiException.fromStatusCode(422);
      expect(unprocessable.message, contains('Please check'));

      final serverError = ApiException.fromStatusCode(500);
      expect(serverError.message, contains('Server is temporarily unavailable'));
    });
  });

  group('FastAPI Model Deserialization Tests', () {
    test('Opportunity.fromJson parses FastAPI response accurately', () {
      final json = {
        'id': 'opp_test_100',
        'title': 'AI Global Hackathon 2026',
        'organization': 'Google Cloud',
        'category': 'hackathon',
        'domain': 'Artificial Intelligence',
        'mode': 'ONLINE',
        'deadline': '2026-10-31T23:59:59Z',
        'description': 'Build multi-modal agents with Gemini and Cloud Run.',
        'eligibility': 'Open to all undergraduate students',
        'location': 'Remote / Virtual',
        'apply_url': 'https://example.com/apply',
        'is_featured': true,
        'days_left': 29,
        'skills': ['Python', 'Gemini API', 'Docker'],
      };

      final opp = Opportunity.fromJson(json);
      expect(opp.id, equals('opp_test_100'));
      expect(opp.title, equals('AI Global Hackathon 2026'));
      expect(opp.organization, equals('Google Cloud'));
      expect(opp.category, equals('hackathon'));
      expect(opp.mode, equals('ONLINE'));
      expect(opp.isFeatured, isTrue);
      expect(opp.daysLeft, equals(29));
      expect(opp.skills.length, equals(3));
      expect(opp.skills, contains('Gemini API'));
    });

    test('Post.fromJson parses FastAPI post response correctly', () {
      final json = {
        'id': 'post_test_200',
        'title': 'How to setup Ghidra for CTFs',
        'content': 'Here is a step by step guide on setting up Ghidra decompiler plugins.',
        'type': 'knowledge',
        'tags': ['cybersecurity', 'ghidra', 'reverse-eng'],
        'author_id': 'user_auth_123',
        'author': {
          'id': 'user_auth_123',
          'full_name': 'Sandeep B',
          'avatar_url': 'https://example.com/avatar.jpg',
        },
        'likes_count': 15,
        'comments_count': 3,
        'is_liked': true,
        'created_at': '2026-10-01T12:00:00Z',
        'comments': [
          {
            'id': 'c_1',
            'content': 'Great writeup! Very helpful.',
            'author_name': 'Arun Kumar',
            'created_at': '2026-10-01T13:00:00Z',
          }
        ],
      };

      final post = Post.fromJson(json);
      expect(post.id, equals('post_test_200'));
      expect(post.title, equals('How to setup Ghidra for CTFs'));
      expect(post.type, equals(PostType.knowledge));
      expect(post.authorName, equals('Sandeep B'));
      expect(post.likesCount, equals(15));
      expect(post.isLikedByCurrentUser, isTrue);
      expect(post.comments.length, equals(1));
      expect(post.comments.first.authorName, equals('Arun Kumar'));
    });

    test('UserProfile.fromJson parses FastAPI /me response', () {
      final json = {
        'id': 'user_sandeep_1',
        'email': 'sandeep@kpriet.ac.in',
        'full_name': 'Sandeep B',
        'username': 'sandeepb',
        'college': 'KPR Institute of Engineering and Technology',
        'department': 'Computer Science & Engineering',
        'year': 'Year 3',
        'bio': 'Passionate cybersecurity developer & Flutter builder.',
        'skills': ['Python', 'Dart', 'Flutter', 'FastAPI', 'PostgreSQL'],
        'interests': ['🛡️ Cybersecurity', '📱 Mobile Development'],
        'saved_opportunities': ['opp_test_100'],
        'saved_posts': ['post_test_200'],
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, equals('user_sandeep_1'));
      expect(profile.name, equals('Sandeep B'));
      expect(profile.email, equals('sandeep@kpriet.ac.in'));
      expect(profile.college, equals('KPR Institute of Engineering and Technology'));
      expect(profile.branch, equals('Computer Science & Engineering'));
      expect(profile.year, equals('Year 3'));
      expect(profile.skills.length, equals(5));
      expect(profile.savedOpportunityIds, contains('opp_test_100'));
      expect(profile.savedPostIds, contains('post_test_200'));
    });

    test('Person.fromJson parses /users endpoint response', () {
      final json = {
        'id': 'peer_10',
        'full_name': 'Priya Ramesh',
        'college': 'PSG College of Technology',
        'department': 'Information Technology',
        'year': 'Year 3',
        'bio': 'Competitive coder & open-source contributor.',
        'skills': ['C++', 'Python', 'Go'],
        'interests': ['🧠 Competitive Programming', '💻 Software Development'],
        'mutual_count': 8,
      };

      final person = Person.fromJson(json);
      expect(person.id, equals('peer_10'));
      expect(person.name, equals('Priya Ramesh'));
      expect(person.avatarInitials, equals('PR'));
      expect(person.mutualCount, equals(8));
    });

    test('Group.fromJson parses /groups response', () {
      final json = {
        'id': 'grp_ai',
        'name': 'AI & Vision Research Circle',
        'category': 'AI / ML',
        'description': 'Student research group building multi-modal LLM applications.',
        'members_count': 42,
        'rules': ['Share reproducible code', 'Cite sources'],
        'resources': ['ArXiv Weekly', 'PyTorch Templates'],
        'events': ['Weekly Paper Reading (Thursday 5 PM)'],
      };

      final group = Group.fromJson(json);
      expect(group.id, equals('grp_ai'));
      expect(group.name, equals('AI & Vision Research Circle'));
      expect(group.membersCount, equals(42));
      expect(group.rules.length, equals(2));
    });

    test('Mentor.fromJson parses /mentors response', () {
      final json = {
        'id': 'mentor_crowdstrike',
        'name': 'Rahul Sharma',
        'role': 'Senior Security Researcher @ CrowdStrike',
        'college': 'Alumnus · IIT Madras (2022)',
        'experience': '4+ Years Industry Experience',
        'badge': 'Cybersecurity Mentor',
        'about': 'Passionate about guiding students into security engineering.',
        'skills': ['Reverse Engineering', 'Ghidra', 'Kernel Security'],
        'topics': ['Breaking into Cybersecurity', 'Preparing for CTFs'],
      };

      final mentor = Mentor.fromJson(json);
      expect(mentor.id, equals('mentor_crowdstrike'));
      expect(mentor.name, equals('Rahul Sharma'));
      expect(mentor.skills.length, equals(3));
      expect(mentor.badge, equals('Cybersecurity Mentor'));
    });

    test('NotificationItem.fromJson parses /notifications response', () {
      final json = {
        'id': 'notif_99',
        'title': 'New Opportunity Scouted',
        'message': 'Google Summer of Code 2026 is announced.',
        'type': 'opportunity',
        'is_read': false,
        'time_ago': '10m ago',
      };

      final notif = NotificationItem.fromJson(json);
      expect(notif.id, equals('notif_99'));
      expect(notif.type, equals(NotificationType.opportunity));
      expect(notif.isRead, isFalse);
    });
  });

  group('ApiClient Token & Request Construction Tests', () {
    test('ApiClient singleton manages auth tokens correctly', () {
      final client = ApiClient.instance;
      expect(client.isAuthenticated, isFalse);

      client.setAuthToken('test_firebase_bearer_token');
      expect(client.isAuthenticated, isTrue);

      client.clearAuthToken();
      expect(client.isAuthenticated, isFalse);
    });
  });
}
