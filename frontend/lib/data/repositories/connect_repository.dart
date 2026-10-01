import 'package:flutter/foundation.dart';
import '../../core/services/api_client.dart';
import '../models/person.dart';
import '../models/group.dart';
import '../models/mentor.dart';

/// Repository managing People, Groups, and Mentors backed by FastAPI / PostgreSQL.
class ConnectRepository extends ChangeNotifier {
  static const List<Person> _initialPeople = [
    Person(
      id: 'peer_1',
      name: 'Arun Kumar',
      college: 'KPR Institute of Engineering and Technology',
      branch: 'Computer Science & Engineering',
      year: 'Year 3',
      role: 'Cybersecurity · Linux · CTF Player',
      bio: 'Ranked top 100 on TryHackMe India. Passionate about reverse engineering, network security, and organizing collegiate CTFs.',
      avatarInitials: 'AK',
      skills: ['Network Security', 'Wireshark', 'Python', 'Reverse Eng', 'Linux'],
      interests: ['🛡️ Cybersecurity', '🔌 Networking', '🏆 Hackathons'],
      mutualCount: 4,
    ),
    Person(
      id: 'peer_2',
      name: 'Sneha Patel',
      college: 'PSG College of Technology',
      branch: 'Information Technology',
      year: 'Year 3',
      role: 'Full Stack & Mobile Dev',
      bio: 'Building cross-platform apps with Flutter and Go. Open source contributor and hackathon enthusiast.',
      avatarInitials: 'SP',
      skills: ['Flutter', 'Dart', 'Node.js', 'PostgreSQL', 'Docker'],
      interests: ['💻 Software Development', '📱 Mobile Development', '🏆 Hackathons'],
      mutualCount: 7,
    ),
    Person(
      id: 'peer_3',
      name: 'Ananya Sharma',
      college: 'Coimbatore Institute of Technology',
      branch: 'Artificial Intelligence & Data Science',
      year: 'Year 3',
      role: 'AI Researcher & Systems Builder',
      bio: 'Researching multi-modal LLMs and compact vision transformers. Co-author of 2 IEEE student papers.',
      avatarInitials: 'AS',
      skills: ['PyTorch', 'Rust', 'Computer Vision', 'LangChain', 'Python'],
      interests: ['🤖 AI / ML', '🔬 Research & Papers', '📊 Data Science'],
      mutualCount: 5,
    ),
    Person(
      id: 'peer_4',
      name: 'Deepak V',
      college: 'KPR Institute of Engineering and Technology',
      branch: 'Computer Science & Engineering',
      year: 'Year 4',
      role: 'Cloud & DevOps Engineer',
      bio: 'CKA Certified. Passionate about Kubernetes operator design, Terraform, and high availability systems.',
      avatarInitials: 'DV',
      skills: ['AWS', 'Kubernetes', 'Terraform', 'CI/CD', 'Docker'],
      interests: ['☁️ Cloud & DevOps', '🏗️ System Design', '🔌 Networking'],
      mutualCount: 11,
    ),
    Person(
      id: 'peer_5',
      name: 'Karthik Raja',
      college: 'Kumaraguru College of Technology',
      branch: 'Computer Science & Engineering',
      year: 'Year 3',
      role: 'Competitive Programmer (Candidate Master)',
      bio: 'Active Codeforces and CodeChef solver. Mentoring junior students in graph algorithms and dynamic programming.',
      avatarInitials: 'KR',
      skills: ['C++', 'Data Structures', 'Algorithms', 'Graph Theory', 'Math'],
      interests: ['🧠 Competitive Programming', '💻 Software Development'],
      mutualCount: 3,
    ),
    Person(
      id: 'peer_6',
      name: 'Sahana M',
      college: 'KPR Institute of Engineering and Technology',
      branch: 'Artificial Intelligence & Machine Learning',
      year: 'Year 4',
      role: 'ML Engineer & Kaggle 2x Expert',
      bio: 'Specializing in tabular machine learning, feature engineering, and deploying model inference pipelines on FastAPI.',
      avatarInitials: 'SM',
      skills: ['Scikit-learn', 'XGBoost', 'FastAPI', 'Pandas', 'MLOps'],
      interests: ['🤖 AI / ML', '📊 Data Science', '☁️ Cloud & DevOps'],
      mutualCount: 6,
    ),
  ];

  static const List<Group> _initialGroups = [
    Group(
      id: 'group_1',
      name: 'Cybersecurity & CTF Builders',
      category: 'Cybersecurity',
      description: 'Collegiate ethical hacking group practicing TryHackMe, HackTheBox, reverse engineering, binary exploitation, and collegiate CTF sprints.',
      membersCount: 42,
      iconName: 'security',
      rules: [
        'Ethical research and authorized CTF challenges only.',
        'Share detailed writeups with reproducible PoCs.',
        'Collaborate respectfully during collegiate competitions.',
      ],
      resources: [
        'KPR CTF Archive & Walkthroughs (Notion)',
        'Ghidra & Radare2 Cheat Sheets',
        'Buffer Overflow Practice Binaries (GitHub)',
      ],
      events: [
        'Weekly CTF Sprint (Every Saturday 8 PM)',
        'Binary Exploitation Deep Dive (Wednesday 6 PM)',
      ],
    ),
    Group(
      id: 'group_2',
      name: 'AI & Vision Research Circle',
      category: 'AI / ML',
      description: 'Student research group building multi-modal LLM applications, fine-tuning open-weights models, and publishing IEEE student workshop papers.',
      membersCount: 38,
      iconName: 'ai',
      rules: [
        'Focus on reproducible experiments and open-source models.',
        'Always cite academic sources and papers properly.',
        'Constructive feedback during weekly paper reading sessions.',
      ],
      resources: [
        'ArXiv Weekly Highlights (Discord)',
        'PyTorch LoRA Fine-Tuning Templates',
        'Google Colab GPU Allocation Tips',
      ],
      events: [
        'Paper Reading Session: Vision Transformers (Thursday 5 PM)',
        'LangChain & RAG Workshop (Sunday 11 AM)',
      ],
    ),
    Group(
      id: 'group_3',
      name: 'Mobile & Cloud Native Guild',
      category: 'Software Engineering',
      description: 'Building production mobile apps with Flutter, distributed backend microservices on FastAPI & Go, and automated CI/CD on Kubernetes.',
      membersCount: 56,
      iconName: 'code',
      rules: [
        'Clean code principles and structured Git workflows.',
        'Pair programming and constructive PR reviews.',
        'Zero tolerance for low-effort or plagiarized assignments.',
      ],
      resources: [
        'Flutter Architecture Guide (Clean / Feature-first)',
        'FastAPI Production Template Repo',
        'Docker & Kubernetes Local Lab Setup',
      ],
      events: [
        'Open Source Sprint (1st & 3rd Weekend of Month)',
        'Microservices System Design Breakdown (Tuesday 7 PM)',
      ],
    ),
  ];

  static const List<Mentor> _initialMentors = [
    Mentor(
      id: 'mentor_1',
      name: 'Rahul Sharma',
      role: 'Senior Security Researcher @ CrowdStrike',
      college: 'Alumnus · IIT Madras (2022)',
      experience: '4+ Years Industry Experience',
      badge: 'Cybersecurity Mentor',
      about: 'Passionate about guiding students into security engineering, reverse engineering, and threat intelligence. Mentored 20+ students for Google SOC and top CTFs.',
      skills: ['Reverse Engineering', 'Malware Analysis', 'Kernel Security', 'C++', 'Threat Hunting'],
      topics: [
        'Breaking into Cybersecurity from College',
        'How to Prepare for CTF Competitions',
        'Reverse Engineering Malware with Ghidra',
        'Resume & Portfolio Review for Security Roles',
      ],
      sessions: [
        LearningSession(
          id: 'sess_1',
          title: 'Practical Packet Analysis with Wireshark',
          description: 'Hands-on session dissecting real PCAP captures, identifying C2 beacons, and protocol anomalies.',
          duration: '45 mins · 1-on-1',
        ),
        LearningSession(
          id: 'sess_2',
          title: 'CTF Binary Exploitation Roadmap',
          description: 'Step-by-step guidance on buffer overflows, format string bugs, and ROP chain exploitation.',
          duration: '60 mins · Interactive',
        ),
      ],
    ),
    Mentor(
      id: 'mentor_2',
      name: 'Dr. Priya Venkatesh',
      role: 'Associate Professor & AI Lab Director',
      college: 'KPR Institute of Engineering and Technology',
      experience: '12+ Years Academic & Research',
      badge: 'Faculty Mentor',
      about: 'Guiding undergraduate students on IEEE/ACM research publications, grant proposals, and competitive international hackathon projects.',
      skills: ['Machine Learning', 'Computer Vision', 'Research Methodology', 'Deep Learning', 'PyTorch'],
      topics: [
        'Writing Your First High-Impact Research Paper',
        'Choosing an M.Tech / MS Research Specialization',
        'Model Interpretability & Explainable AI',
      ],
      sessions: [
        LearningSession(
          id: 'sess_3',
          title: 'Research Topic Formulation & Literature Review',
          description: 'How to discover novel research gaps in top conferences (CVPR, NeurIPS, ACL).',
          duration: '45 mins · Consultation',
        ),
      ],
    ),
  ];

  final ValueNotifier<List<Person>> _peopleNotifier = ValueNotifier<List<Person>>(_initialPeople);
  final ValueNotifier<List<Group>> _groupsNotifier = ValueNotifier<List<Group>>(_initialGroups);
  final ValueNotifier<List<Mentor>> _mentorsNotifier = ValueNotifier<List<Mentor>>(_initialMentors);

  ValueListenable<List<Person>> get peopleNotifier => _peopleNotifier;
  ValueListenable<List<Group>> get groupsNotifier => _groupsNotifier;
  ValueListenable<List<Mentor>> get mentorsNotifier => _mentorsNotifier;

  List<Person> get allPeople => _peopleNotifier.value;
  List<Group> get allGroups => _groupsNotifier.value;
  List<Mentor> get allMentors => _mentorsNotifier.value;

  ConnectRepository() {
    fetchPeople();
    fetchGroups();
    fetchMentors();
  }

  /// Fetches registered student peers from GET /api/v1/users.
  Future<void> fetchPeople({String query = '', int page = 1, int limit = 30}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (query.isNotEmpty) queryParams['query'] = query;

      final response = await ApiClient.instance.get('users', queryParams: queryParams);
      if (response is Map && response['items'] is List) {
        final items = (response['items'] as List)
            .map((json) => Person.fromJson(json as Map<String, dynamic>))
            .toList();
        if (items.isNotEmpty) {
          _peopleNotifier.value = items;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[ConnectRepository] Backend users fetch notice: $e');
    }
  }

  /// Fetches groups from GET /api/v1/groups.
  Future<void> fetchGroups() async {
    try {
      final response = await ApiClient.instance.get('groups');
      if (response is List) {
        final items = response.map((json) => Group.fromJson(json as Map<String, dynamic>)).toList();
        if (items.isNotEmpty) {
          _groupsNotifier.value = items;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[ConnectRepository] Backend groups fetch notice: $e');
    }
  }

  /// Fetches mentors from GET /api/v1/mentors.
  Future<void> fetchMentors() async {
    try {
      final response = await ApiClient.instance.get('mentors');
      if (response is List) {
        final items = response.map((json) => Mentor.fromJson(json as Map<String, dynamic>)).toList();
        if (items.isNotEmpty) {
          _mentorsNotifier.value = items;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[ConnectRepository] Backend mentors fetch notice: $e');
    }
  }

  /// Refreshes all people, groups, and mentors from the backend.
  Future<void> refresh() async {
    await Future.wait([
      fetchPeople(),
      fetchGroups(),
      fetchMentors(),
    ]);
  }

  Person? getPersonById(String id) {
    try {
      return _peopleNotifier.value.firstWhere((p) => p.id == id);
    } catch (_) {
      try {
        return _initialPeople.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Group? getGroupById(String id) {
    try {
      return _groupsNotifier.value.firstWhere((g) => g.id == id);
    } catch (_) {
      try {
        return _initialGroups.firstWhere((g) => g.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Mentor? getMentorById(String id) {
    try {
      return _mentorsNotifier.value.firstWhere((m) => m.id == id);
    } catch (_) {
      try {
        return _initialMentors.firstWhere((m) => m.id == id);
      } catch (_) {
        return null;
      }
    }
  }
}
