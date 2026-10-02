import 'package:flutter/foundation.dart';
import '../../core/services/api_client.dart';
import '../models/opportunity.dart';

/// Repository managing opportunity data from FastAPI / PostgreSQL backend with defensive fallback.
class OpportunityRepository {
  static const List<Opportunity> _initialOpportunities = [
    Opportunity(
      id: 'opp_1',
      title: 'Google GenAI Hackathon 2025',
      organization: 'Google',
      category: 'Hackathons',
      domain: 'AI / ML',
      description: 'Build innovative AI-powered solutions to solve real-world problems. Open to all students across India. Collaborate in teams of up to 4 to craft transformative generative AI applications using Gemini 2.0 and Vertex AI.',
      eligibility: 'All college undergraduate & postgraduate students in India',
      skills: ['Python', 'Gemini API', 'Vertex AI', 'Flutter', 'FastAPI'],
      location: 'Online',
      mode: 'Online',
      prize: '₹5,00,000',
      deadline: '2026-10-18',
      source: 'Google Developer Student Clubs',
      registrationUrl: 'https://developers.google.com/community/gdsc',
      isFeatured: true,
      daysLeft: 12,
    ),
    Opportunity(
      id: 'opp_2',
      title: 'Product Design Intern',
      organization: 'Flipkart',
      category: 'Internships',
      domain: 'Product & Design',
      description: 'Join the consumer experience team at Flipkart to design delightful mobile and web interfaces for over 500 million shoppers.',
      eligibility: 'Pre-final and Final year students in Design, CS, or related disciplines',
      skills: ['Figma', 'UI/UX', 'Design Systems', 'User Research', 'Prototyping'],
      location: 'Bengaluru / Remote',
      mode: 'Remote',
      prize: 'Stipend ₹65,000/mo',
      salary: '₹65,000/month',
      deadline: '2026-10-11',
      source: 'Flipkart Careers',
      registrationUrl: 'https://flipkartcareers.com',
      isClosingSoon: true,
      daysLeft: 5,
    ),
    Opportunity(
      id: 'opp_3',
      title: 'Cybersecurity Workshop',
      organization: 'ISRO',
      category: 'Events',
      domain: 'Cybersecurity',
      description: 'Hands-on practical training on satellite telemetry network security, threat mitigation, and SCADA infrastructure defense.',
      eligibility: 'Open to 2nd, 3rd, and 4th year Engineering students',
      skills: ['Network Security', 'Wireshark', 'SCADA', 'Cryptography', 'Linux'],
      location: 'Online Workshop',
      mode: 'Online',
      prize: 'Free Certification',
      deadline: '2026-10-09',
      source: 'ISRO Student Program',
      registrationUrl: 'https://isro.gov.in',
      isClosingSoon: true,
      daysLeft: 3,
    ),
    Opportunity(
      id: 'opp_4',
      title: 'Code for Impact',
      organization: 'Tata Consultancy Services',
      category: 'Hackathons',
      domain: 'Software Engineering',
      description: 'National coding hackathon focused on sustainable supply chains, clean energy tech, and accessible healthcare solutions.',
      eligibility: 'All engineering & science undergraduates',
      skills: ['Java', 'Spring Boot', 'React', 'PostgreSQL', 'Docker'],
      location: 'Online',
      mode: 'Online',
      prize: '₹3,00,000',
      deadline: '2026-10-21',
      source: 'TCS Campus Portal',
      registrationUrl: 'https://tcs.com/careers',
      daysLeft: 15,
    ),
    Opportunity(
      id: 'opp_5',
      title: 'AI Innovation Challenge',
      organization: 'Microsoft',
      category: 'Hackathons',
      domain: 'AI / ML',
      description: 'Build enterprise-grade copilot extensions and autonomous agent workflows on Microsoft Azure AI Studio.',
      eligibility: 'Enrolled students worldwide',
      skills: ['Azure OpenAI', 'Semantic Kernel', 'TypeScript', 'Python'],
      location: 'Online',
      mode: 'Online',
      prize: '₹5,00,000',
      deadline: '2026-10-14',
      source: 'Microsoft Imagine Cup',
      registrationUrl: 'https://imaginecup.microsoft.com',
      daysLeft: 8,
    ),
    Opportunity(
      id: 'opp_6',
      title: 'Unstop x AWS Hackathon',
      organization: 'AWS',
      category: 'Hackathons',
      domain: 'Cloud & DevOps',
      description: 'Architect resilient serverless applications, containerized event pipelines, and scalable cloud native systems.',
      eligibility: 'Undergraduate and Master students',
      skills: ['AWS Lambda', 'DynamoDB', 'Docker', 'Terraform', 'Node.js'],
      location: 'Online',
      mode: 'Online',
      prize: '₹3,00,000',
      deadline: '2026-10-16',
      source: 'AWS Student Community',
      registrationUrl: 'https://aws.amazon.com/events',
      daysLeft: 10,
    ),
    Opportunity(
      id: 'opp_7',
      title: 'National Cyber Challenge',
      organization: 'IIT Bombay',
      category: 'Hackathons',
      domain: 'Cybersecurity',
      description: 'Flagship collegiate CTF challenge featuring reverse engineering, binary exploitation, web vulnerabilities, and forensics.',
      eligibility: 'Student teams of 1-3 members',
      skills: ['Reverse Engineering', 'GDB', 'Web Security', 'Forensics', 'C'],
      location: 'Online',
      mode: 'Online',
      prize: '₹2,50,000',
      deadline: '2026-10-13',
      source: 'IIT Bombay Techfest',
      registrationUrl: 'https://techfest.org',
      daysLeft: 7,
    ),
    Opportunity(
      id: 'opp_8',
      title: 'Security Analyst Internship',
      organization: 'CrowdStrike',
      category: 'Internships',
      domain: 'Cybersecurity',
      description: 'Work alongside threat intelligence specialists on incident triage, malware behavioral analysis, and kernel endpoint monitoring.',
      eligibility: '3rd and 4th year Computer Science or Cybersecurity students',
      skills: ['Threat Hunting', 'SIEM', 'Python', 'Linux', 'Memory Forensics'],
      location: 'Bengaluru / Hybrid',
      mode: 'Hybrid',
      prize: '₹45,000/mo',
      salary: '₹45,000/month',
      deadline: '2026-10-10',
      source: 'CrowdStrike Careers',
      registrationUrl: 'https://crowdstrike.com/careers',
      isClosingSoon: true,
      daysLeft: 4,
    ),
  ];

  final ValueNotifier<List<Opportunity>> _opportunitiesNotifier =
      ValueNotifier<List<Opportunity>>(_initialOpportunities);
  final ValueNotifier<List<Opportunity>> _savedOpportunitiesNotifier =
      ValueNotifier<List<Opportunity>>([]);

  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNext = false;

  ValueListenable<List<Opportunity>> get opportunitiesNotifier => _opportunitiesNotifier;
  ValueListenable<List<Opportunity>> get savedOpportunitiesNotifier => _savedOpportunitiesNotifier;
  List<Opportunity> get allOpportunities => _opportunitiesNotifier.value;
  bool get isLoading => _isLoading;
  bool get hasNextPage => _hasNext;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  OpportunityRepository() {
    fetchOpportunities();
    fetchSavedOpportunities();
  }

  /// Fetches real opportunities from FastAPI with comprehensive filters.
  Future<void> fetchOpportunities({
    String query = '',
    String category = 'All',
    String? domain,
    String? mode,
    String? skills,
    String sort = 'latest',
    int page = 1,
    int limit = 20,
    bool isRefresh = false,
  }) async {
    _isLoading = true;
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sort': sort,
      };

      if (query.isNotEmpty) queryParams['search'] = query;
      if (category != 'All' && category.isNotEmpty) queryParams['category'] = category;
      if (domain != null && domain != 'All' && domain.isNotEmpty) queryParams['domain'] = domain;
      if (mode != null && mode != 'All' && mode.isNotEmpty) queryParams['mode'] = mode.toUpperCase();
      if (skills != null && skills.isNotEmpty) queryParams['skills'] = skills;

      final response = await ApiClient.instance.get('opportunities', queryParams: queryParams);
      if (response is Map && response['items'] is List) {
        final items = (response['items'] as List)
            .map((json) => Opportunity.fromJson(json as Map<String, dynamic>))
            .toList();

        _currentPage = response['page'] as int? ?? page;
        _totalPages = response['total_pages'] as int? ?? 1;
        _hasNext = response['has_next'] as bool? ?? false;

        if (page == 1 || isRefresh) {
          _opportunitiesNotifier.value = items.isNotEmpty ? items : _initialOpportunities;
        } else {
          _opportunitiesNotifier.value = [..._opportunitiesNotifier.value, ...items];
        }
      }
    } catch (e) {
      debugPrint('[OpportunityRepository] Backend fetch notice (using local cache): $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Fetches user saved opportunities from GET /api/v1/me/saved-opportunities.
  Future<void> fetchSavedOpportunities() async {
    try {
      final response = await ApiClient.instance.get('me/saved-opportunities');
      if (response is Map && response['items'] is List) {
        final items = (response['items'] as List)
            .map((json) => Opportunity.fromJson(json as Map<String, dynamic>))
            .toList();
        _savedOpportunitiesNotifier.value = items;
      }
    } catch (e) {
      debugPrint('[OpportunityRepository] Saved opportunities sync: $e');
    }
  }

  /// Toggles saving an opportunity with optimistic UI and live API sync via POST /api/v1/opportunities/{id}/save.
  Future<void> toggleSaveOpportunity(String opportunityId) async {
    final currentList = List<Opportunity>.from(_opportunitiesNotifier.value);
    final index = currentList.indexWhere((o) => o.id == opportunityId);
    if (index != -1) {
      final opp = currentList[index];
      final isSaved = !opp.isSavedByCurrentUser;
      currentList[index] = opp.copyWith(isSavedByCurrentUser: isSaved);
      _opportunitiesNotifier.value = currentList;

      final currentSaved = List<Opportunity>.from(_savedOpportunitiesNotifier.value);
      if (isSaved) {
        if (!currentSaved.any((o) => o.id == opportunityId)) {
          currentSaved.add(currentList[index]);
        }
      } else {
        currentSaved.removeWhere((o) => o.id == opportunityId);
      }
      _savedOpportunitiesNotifier.value = currentSaved;

      try {
        if (isSaved) {
          await ApiClient.instance.post('opportunities/$opportunityId/save');
        } else {
          await ApiClient.instance.delete('opportunities/$opportunityId/save');
        }
      } catch (e) {
        debugPrint('[OpportunityRepository] Save toggle notice: $e');
      }
    }
  }

  /// Fetches single opportunity details by ID from GET /api/v1/opportunities/{id}.
  Future<Opportunity?> getOpportunityById(String id) async {
    try {
      final response = await ApiClient.instance.get('opportunities/$id');
      if (response is Map<String, dynamic>) {
        return Opportunity.fromJson(response);
      }
    } catch (e) {
      debugPrint('[OpportunityRepository] Get opportunity by ID error: $e');
    }
    return getById(id);
  }

  /// Local quick filter helper for instantaneous UI searches and offline scenarios.
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
      try {
        return _initialOpportunities.firstWhere((o) => o.id == id);
      } catch (_) {
        return null;
      }
    }
  }
}
