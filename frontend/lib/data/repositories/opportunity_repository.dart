import 'package:flutter/foundation.dart';
import '../models/opportunity.dart';

/// Repository managing opportunity data, search filtering, and bookmarking.
class OpportunityRepository {
  final ValueNotifier<List<Opportunity>> _opportunitiesNotifier = ValueNotifier<List<Opportunity>>([]);

  ValueListenable<List<Opportunity>> get opportunitiesNotifier => _opportunitiesNotifier;
  List<Opportunity> get allOpportunities => _opportunitiesNotifier.value;

  OpportunityRepository() {
    _initDummyData();
  }

  void _initDummyData() {
    _opportunitiesNotifier.value = const [
      Opportunity(
        id: 'opp_1',
        title: 'Global AI Innovation Sprint 2026',
        organization: 'Google Cloud & DeepMind',
        category: 'Hackathons',
        domain: 'AI / ML',
        description: 'Build high-impact multimodal applications solving real-world challenges in healthcare, education, and climate resilience using Gemini and Vertex AI.',
        eligibility: 'All undergraduate and postgraduate college students with valid student ID.',
        skills: ['Python', 'Gemini API', 'Flutter', 'PyTorch', 'Prompt Engineering'],
        location: 'Online / Global',
        mode: 'Online',
        prize: '\$25,000 USD Prize Pool + Cloud Credits',
        deadline: 'Oct 28, 2026',
        source: 'Google Cloud Developers',
        registrationUrl: 'https://developers.google.com/events',
        isFeatured: true,
        isClosingSoon: false,
        daysLeft: 27,
      ),
      Opportunity(
        id: 'opp_2',
        title: 'Cybersecurity Analyst Summer Internship',
        organization: 'CrowdStrike',
        category: 'Internships',
        domain: 'Cybersecurity',
        description: 'Join the Threat Intelligence and Incident Response team for a 3-month paid summer internship. Work on malware triage, packet analysis, and threat hunting telemetry.',
        eligibility: 'Pre-final and Final year CS, IT, and Cybersecurity undergraduate students.',
        skills: ['Wireshark', 'Python', 'Linux CLI', 'Threat Intel', 'Network Security'],
        location: 'Bengaluru / Remote',
        mode: 'Hybrid',
        prize: 'Paid Internship',
        salary: '₹60,000 / month',
        deadline: 'Oct 05, 2026',
        source: 'CrowdStrike University Careers',
        registrationUrl: 'https://www.crowdstrike.com/careers',
        isFeatured: false,
        isClosingSoon: true,
        daysLeft: 4,
      ),
      Opportunity(
        id: 'opp_3',
        title: 'National Collegiate Web3 Challenge',
        organization: 'Polygon Labs',
        category: 'Competitions',
        domain: 'Blockchain & Web3',
        description: 'Build decentralized applications focusing on zero-knowledge rollups, micropayments for students, and decentralized credential verification.',
        eligibility: 'Open to student teams of up to 4 members across Indian engineering institutions.',
        skills: ['Solidity', 'Rust', 'Ethers.js', 'Next.js', 'Smart Contracts'],
        location: 'Bengaluru, India',
        mode: 'Hybrid',
        prize: '₹5,00,000 Cash Prize + Grant Funding',
        deadline: 'Oct 08, 2026',
        source: 'Polygon Dev Hub',
        registrationUrl: 'https://polygon.technology',
        isFeatured: false,
        isClosingSoon: true,
        daysLeft: 7,
      ),
      Opportunity(
        id: 'opp_4',
        title: 'Full-Stack Developer Intern (Flutter & Go)',
        organization: 'Zerodha Tech',
        category: 'Internships',
        domain: 'Software Development',
        description: 'Work with the mobile and high-throughput backend infrastructure team building real-time market data visualization widgets and low-latency APIs.',
        eligibility: 'Students in 2nd, 3rd or 4th year with strong data structures and Flutter/Dart or Go experience.',
        skills: ['Flutter', 'Dart', 'Go', 'WebSockets', 'PostgreSQL'],
        location: 'Bengaluru, India',
        mode: 'In-person',
        prize: 'Paid Internship + PPO Opportunity',
        salary: '₹75,000 / month',
        deadline: 'Nov 15, 2026',
        source: 'Zerodha Careers',
        registrationUrl: 'https://zerodha.com/careers',
        isFeatured: true,
        isClosingSoon: false,
        daysLeft: 45,
      ),
      Opportunity(
        id: 'opp_5',
        title: 'Cloud & DevOps Architecture Workshop',
        organization: 'AWS Student Community',
        category: 'Workshops',
        domain: 'Cloud & DevOps',
        description: 'Hands-on 2-day intensive weekend workshop on deploying containerized microservices on AWS EKS with Terraform infrastructure-as-code and GitHub Actions CI/CD.',
        eligibility: 'All students with basic Linux & Docker familiarity. Free participation with completion certificate.',
        skills: ['AWS', 'Kubernetes', 'Docker', 'Terraform', 'CI/CD'],
        location: 'Online',
        mode: 'Online',
        prize: 'Free Certification Voucher + AWS Credits',
        deadline: 'Oct 18, 2026',
        source: 'AWS Community Hub',
        registrationUrl: 'https://aws.amazon.com/events',
        isFeatured: false,
        isClosingSoon: false,
        daysLeft: 17,
      ),
      Opportunity(
        id: 'opp_6',
        title: 'Smart India Hackathon 2026 (Internal College Round)',
        organization: 'Ministry of Education & AICTE',
        category: 'Hackathons',
        domain: 'Software Development',
        description: 'Nationwide initiative providing students a platform to solve pressing problems of ministries, departments, and industry leaders.',
        eligibility: 'Teams of 6 students with at least one female team member.',
        skills: ['Full-stack Web/Mobile', 'IoT', 'AI/ML', 'Cloud', 'System Architecture'],
        location: 'Coimbatore, India',
        mode: 'In-person',
        prize: '₹1,00,000 per Problem Statement',
        deadline: 'Oct 12, 2026',
        source: 'AICTE SIH Portal',
        registrationUrl: 'https://sih.gov.in',
        isFeatured: true,
        isClosingSoon: true,
        daysLeft: 11,
      ),
      Opportunity(
        id: 'opp_7',
        title: 'Junior Security Researcher (Threat Intel)',
        organization: 'SentinelOne',
        category: 'Jobs',
        domain: 'Cybersecurity',
        description: 'Full-time entry-level opportunity for graduating students passionate about endpoint security, reverse engineering, and threat detection engineering.',
        eligibility: 'Graduating batch of 2026/2027 (BE/B.Tech/MCA/M.Tech).',
        skills: ['C/C++', 'Ghidra / IDA', 'x86/x64 Assembly', 'YARA', 'Windows Internals'],
        location: 'Hyderabad / Remote',
        mode: 'Hybrid',
        prize: 'Full-Time Employment',
        salary: '₹14 - 18 LPA CTC',
        deadline: 'Nov 30, 2026',
        source: 'SentinelOne Talent Hub',
        registrationUrl: 'https://www.sentinelone.com/careers',
        isFeatured: false,
        isClosingSoon: false,
        daysLeft: 60,
      ),
      Opportunity(
        id: 'opp_8',
        title: 'IEEE International Student Research Symposium',
        organization: 'IEEE Computer Society',
        category: 'Events',
        domain: 'Research & Papers',
        description: 'Submit original student research papers in Artificial Intelligence, Cyber-Physical Systems, Edge Computing, and Quantum Algorithms.',
        eligibility: 'Undergraduate, Master, and PhD student authors.',
        skills: ['LaTeX', 'Academic Research', 'Experimental Benchmarking', 'Data Analysis'],
        location: 'Chennai, India',
        mode: 'Hybrid',
        prize: 'IEEE Xplore Publication + Best Paper Award (\$1,000)',
        deadline: 'Nov 10, 2026',
        source: 'IEEE Xplore Symposium',
        registrationUrl: 'https://www.ieee.org/conferences',
        isFeatured: false,
        isClosingSoon: false,
        daysLeft: 40,
      ),
      Opportunity(
        id: 'opp_9',
        title: 'ACM ICPC Regional Preliminary Contest',
        organization: 'ICPC International Foundation',
        category: 'Competitions',
        domain: 'Competitive Programming',
        description: 'The premier global collegiate programming contest. Solve challenging algorithmic problems under tight time and memory constraints.',
        eligibility: 'Teams of 3 students enrolled in the same university.',
        skills: ['C++', 'Algorithms', 'Data Structures', 'Dynamic Programming', 'Graph Theory'],
        location: 'Online Preliminary',
        mode: 'Online',
        prize: 'Advancement to World Finals + Medals',
        deadline: 'Oct 22, 2026',
        source: 'ICPC Global',
        registrationUrl: 'https://icpc.global',
        isFeatured: false,
        isClosingSoon: false,
        daysLeft: 21,
      ),
      Opportunity(
        id: 'opp_10',
        title: 'Hands-on Generative AI & RAG Masterclass',
        organization: 'Hugging Face Student Chapter',
        category: 'Workshops',
        domain: 'AI / ML',
        description: 'Practical masterclass on indexing vector embeddings with Qdrant, building custom agentic workflows with LangGraph, and deploying on Hugging Face Spaces.',
        eligibility: 'All students with basic Python knowledge. Beginner friendly.',
        skills: ['Python', 'LangChain', 'Qdrant', 'Hugging Face', 'Transformers'],
        location: 'Online Interactive',
        mode: 'Online',
        prize: 'Verified Certificate + GPU Compute Hours',
        deadline: 'Oct 14, 2026',
        source: 'Hugging Face Community',
        registrationUrl: 'https://huggingface.co',
        isFeatured: false,
        isClosingSoon: true,
        daysLeft: 13,
      ),
    ];
  }

  List<Opportunity> filterOpportunities({
    String query = '',
    String category = 'All',
    String? domain,
  }) {
    return _opportunitiesNotifier.value.where((opp) {
      final matchesCategory = category == 'All' ||
          opp.category.toLowerCase().contains(category.toLowerCase()) ||
          category.toLowerCase().contains(opp.category.toLowerCase());

      final matchesDomain = domain == null ||
          domain == 'All' ||
          opp.domain.toLowerCase().contains(domain.toLowerCase());

      final matchesQuery = query.isEmpty ||
          opp.title.toLowerCase().contains(query.toLowerCase()) ||
          opp.organization.toLowerCase().contains(query.toLowerCase()) ||
          opp.domain.toLowerCase().contains(query.toLowerCase()) ||
          opp.skills.any((s) => s.toLowerCase().contains(query.toLowerCase())) ||
          opp.description.toLowerCase().contains(query.toLowerCase());

      return matchesCategory && matchesDomain && matchesQuery;
    }).toList();
  }

  Opportunity? getById(String id) {
    try {
      return _opportunitiesNotifier.value.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
