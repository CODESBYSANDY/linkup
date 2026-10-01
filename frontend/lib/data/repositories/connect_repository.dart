import 'package:flutter/foundation.dart';
import '../models/person.dart';
import '../models/group.dart';
import '../models/mentor.dart';

/// Repository managing People, Groups, and Mentors in the Connect ecosystem.
class ConnectRepository {
  final ValueNotifier<List<Person>> _peopleNotifier = ValueNotifier<List<Person>>([]);
  final ValueNotifier<List<Group>> _groupsNotifier = ValueNotifier<List<Group>>([]);
  final ValueNotifier<List<Mentor>> _mentorsNotifier = ValueNotifier<List<Mentor>>([]);

  ValueListenable<List<Person>> get peopleNotifier => _peopleNotifier;
  ValueListenable<List<Group>> get groupsNotifier => _groupsNotifier;
  ValueListenable<List<Mentor>> get mentorsNotifier => _mentorsNotifier;

  List<Person> get allPeople => _peopleNotifier.value;
  List<Group> get allGroups => _groupsNotifier.value;
  List<Mentor> get allMentors => _mentorsNotifier.value;

  ConnectRepository() {
    _initData();
  }

  void _initData() {
    _peopleNotifier.value = const [
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
        interests: ['🤖 AI / ML', '📊 Data Science', '🔬 Research & Papers'],
        mutualCount: 8,
      ),
      Person(
        id: 'peer_7',
        name: 'Vikram S',
        college: 'Government College of Technology',
        branch: 'Electronics & Communication',
        year: 'Year 3',
        role: 'IoT & Embedded Systems Engineer',
        bio: 'Designing custom PCB sensor modules, firmware in Embedded C, and MQTT message brokers.',
        avatarInitials: 'VS',
        skills: ['Embedded C', 'ESP32', 'FreeRTOS', 'MQTT', 'KiCAD'],
        interests: ['⚡ IoT & Embedded', '🔌 Networking', '🏆 Hackathons'],
        mutualCount: 2,
      ),
      Person(
        id: 'peer_8',
        name: 'Priya R',
        college: 'Sri Krishna College of Engineering',
        branch: 'Computer Science & Engineering',
        year: 'Year 2',
        role: 'Web3 & Backend Developer',
        bio: 'Exploring zero knowledge proofs, Ethereum smart contract security audits, and decentralized identity.',
        avatarInitials: 'PR',
        skills: ['Solidity', 'Rust', 'Ethers.js', 'Go', 'Next.js'],
        interests: ['⛓️ Blockchain & Web3', '🛡️ Cybersecurity', '🏗️ System Design'],
        mutualCount: 6,
      ),
    ];

    _groupsNotifier.value = const [
      Group(
        id: 'grp_1',
        name: 'Cybersecurity & CTF Builders',
        category: 'Cybersecurity',
        description: 'Hands-on practice, room writeups, and team formation for national hackathons and CTF challenges.',
        membersCount: 126,
        iconName: 'security',
      ),
      Group(
        id: 'grp_2',
        name: 'AI/ML Research & Paper Club',
        category: 'AI & Data Science',
        description: 'Weekly breakdown of open-access research papers, LLM architectures, and practical fine-tuning workflows.',
        membersCount: 210,
        iconName: 'ai',
      ),
      Group(
        id: 'grp_3',
        name: 'Competitive Programming League',
        category: 'Algorithms',
        description: 'Weekly virtual contests, editorial discussions, and problem solving for ICPC and placement rounds.',
        membersCount: 185,
        iconName: 'code',
      ),
      Group(
        id: 'grp_4',
        name: 'Cloud & DevOps Engineers',
        category: 'Cloud',
        description: 'Kubernetes deployment labs, Terraform IaC recipes, AWS certifications, and cloud architecture sharing.',
        membersCount: 142,
        iconName: 'cloud',
      ),
      Group(
        id: 'grp_5',
        name: 'Flutter & Mobile Craft',
        category: 'Mobile',
        description: 'Building sleek, production-grade cross-platform apps with Dart, animations, and clean architecture.',
        membersCount: 168,
        iconName: 'mobile',
      ),
      Group(
        id: 'grp_6',
        name: 'Hackathon Sprint Squad',
        category: 'Hackathons',
        description: 'Find team members, brainstorm product ideas, design pitches, and win hackathons together.',
        membersCount: 290,
        iconName: 'hackathon',
      ),
    ];

    _mentorsNotifier.value = const [
      Mentor(
        id: 'mentor_1',
        name: 'Rahul Sharma',
        role: 'Senior Security Researcher & Alumnus',
        college: 'KPR Institute Alumnus (Now at CrowdStrike)',
        experience: '4+ Years Industry Experience',
        badge: '⭐ Knowledge Mentor',
        about: 'Passionate about guiding students into security engineering, Linux kernel internals, and preparing for collegiate CTFs.',
        skills: ['Network Security', 'Linux Kernel', 'C', 'Security Architecture', 'Reverse Eng'],
        topics: [
          'Practical Wireshark Packet Analysis',
          'Linux CLI & Threat Hunting Fundamentals',
          'Cracking Collegiate CTF Challenges',
          'Security Career Roadmap',
        ],
        sessions: [
          LearningSession(
            id: 'sess_1',
            title: 'Session 1: Network Fundamentals & Traffic Capture',
            description: 'Understanding TCP/IP handshakes, DNS queries, and capturing live PCAP traces.',
            duration: '45 mins',
          ),
          LearningSession(
            id: 'sess_2',
            title: 'Session 2: Packet Analysis & Malware Triage',
            description: 'Filtering malicious beaconing patterns in Wireshark and writing Snort rules.',
            duration: '60 mins',
          ),
          LearningSession(
            id: 'sess_3',
            title: 'Session 3: CTF Preparation & Writeup Methodology',
            description: 'Hands-on live walkthrough of HackTheBox network challenges.',
            duration: '60 mins',
          ),
        ],
      ),
      Mentor(
        id: 'mentor_2',
        name: 'Dr. Meenakshi S',
        role: 'Professor & AI Lab Director',
        college: 'Department of Computer Science',
        experience: '12+ Years Academic & Research Experience',
        badge: '🎓 Faculty Mentor',
        about: 'Advising undergraduate and graduate research papers in deep learning, vision models, and natural language understanding.',
        skills: ['Deep Learning', 'PyTorch', 'Academic Publishing', 'Research Methodology'],
        topics: [
          'Structuring Your First IEEE/Springer Paper',
          'Experimental Benchmarking & Ablation Studies',
          'Transformer Architecture Deep Dive',
        ],
        sessions: [
          LearningSession(
            id: 'sess_4',
            title: 'Session 1: Research Problem Formulation',
            description: 'How to formulate a novel research question and conduct literature surveys.',
            duration: '45 mins',
          ),
          LearningSession(
            id: 'sess_5',
            title: 'Session 2: Scientific Writing & LaTeX Templates',
            description: 'Drafting methodology, figures, and results for peer review acceptance.',
            duration: '50 mins',
          ),
        ],
      ),
      Mentor(
        id: 'mentor_3',
        name: 'Gautam Menon',
        role: 'Staff Platform Engineer',
        college: 'Ex-Amazon / Platform Lead',
        experience: '8+ Years Industry Experience',
        badge: '⚡ Industry Expert',
        about: 'Specialized in large scale distributed systems, Kubernetes clusters, and mentoring students for backend roles.',
        skills: ['Distributed Systems', 'Go', 'Kubernetes', 'PostgreSQL', 'System Design'],
        topics: [
          'Mastering System Design for Placement Interviews',
          'Building Resilient Microservices in Go',
          'Database Sharding & Caching Strategies',
        ],
        sessions: [
          LearningSession(
            id: 'sess_6',
            title: 'Session 1: High-Level System Architecture',
            description: 'Designing URL shortener, rate limiters, and real-time chat backends.',
            duration: '60 mins',
          ),
        ],
      ),
      Mentor(
        id: 'mentor_4',
        name: 'Kavitha R',
        role: 'Senior Mobile Architect',
        college: 'Tech Lead',
        experience: '6+ Years Mobile Experience',
        badge: '📱 Mobile Lead',
        about: 'Passionate Flutter advocate teaching clean state management, custom animation rendering, and high-performance mobile apps.',
        skills: ['Flutter', 'Dart', 'Clean Architecture', 'Mobile UI/UX', 'CI/CD'],
        topics: [
          'Architecting Production Flutter Apps',
          'Advanced Custom Painters & Micro-interactions',
          'Publishing to App Store & Play Store',
        ],
        sessions: [
          LearningSession(
            id: 'sess_7',
            title: 'Session 1: State Decoupling & Reactive Architecture',
            description: 'Creating maintainable mobile foundations with zero widget bloat.',
            duration: '45 mins',
          ),
        ],
      ),
      Mentor(
        id: 'mentor_5',
        name: 'Arvind Swaminathan',
        role: 'ACM ICPC Regionalist & Alumnus',
        college: 'Software Engineer at Microsoft',
        experience: '3+ Years Experience',
        badge: '🧠 CP Specialist',
        about: 'Passionate about training students for ICPC regionals, Google Code Jam style contests, and algorithmic interviews.',
        skills: ['C++', 'Competitive Programming', 'Dynamic Programming', 'Graph Theory'],
        topics: [
          'Advanced Dynamic Programming Patterns',
          'Segment Trees & Fenwick Trees in Contests',
          'Cracking Big Tech Coding Rounds',
        ],
        sessions: [
          LearningSession(
            id: 'sess_8',
            title: 'Session 1: Mastering DP on Trees & Bitmasks',
            description: 'Live problem walkthrough of hard rated Codeforces problems.',
            duration: '60 mins',
          ),
        ],
      ),
    ];
  }

  Person? getPersonById(String id) {
    try {
      return _peopleNotifier.value.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Group? getGroupById(String id) {
    try {
      return _groupsNotifier.value.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  Mentor? getMentorById(String id) {
    try {
      return _mentorsNotifier.value.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
