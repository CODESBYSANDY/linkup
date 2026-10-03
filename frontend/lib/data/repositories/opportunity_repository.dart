import 'package:flutter/foundation.dart';
import '../../core/services/api_client.dart';
import '../models/opportunity.dart';

/// Repository managing opportunity data directly from FastAPI / PostgreSQL backend.
class OpportunityRepository {
  final ValueNotifier<List<Opportunity>> _opportunitiesNotifier =
      ValueNotifier<List<Opportunity>>([]);
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
          _opportunitiesNotifier.value = items;
        } else {
          _opportunitiesNotifier.value = [..._opportunitiesNotifier.value, ...items];
        }
      }
    } catch (e) {
      debugPrint('[OpportunityRepository] Backend fetch notice: $e');
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
        await fetchSavedOpportunities();
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

  /// Local quick filter helper for instantaneous UI searches.
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

  /// Resets state on logout to prevent cross-user data leakage.
  void reset() {
    _savedOpportunitiesNotifier.value = [];
    _opportunitiesNotifier.value = [];
  }
}
