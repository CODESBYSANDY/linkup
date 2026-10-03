import 'package:flutter/foundation.dart';
import '../../core/services/api_client.dart';
import '../models/person.dart';
import '../models/group.dart';
import '../models/mentor.dart';

/// Repository managing People, Groups, and Mentors backed directly by FastAPI / PostgreSQL.
class ConnectRepository extends ChangeNotifier {
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
      if (query.isNotEmpty) queryParams['search'] = query;

      final response = await ApiClient.instance.get('users', queryParams: queryParams);
      if (response is Map && response['items'] is List) {
        final items = (response['items'] as List)
            .map((json) => Person.fromJson(json as Map<String, dynamic>))
            .toList();
        _peopleNotifier.value = items;
        notifyListeners();
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
        _groupsNotifier.value = items;
        notifyListeners();
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
        _mentorsNotifier.value = items;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ConnectRepository] Backend mentors fetch notice: $e');
    }
  }

  /// Toggles peer connection via POST /api/v1/connections/{userId}.
  Future<bool> toggleConnect(String userId) async {
    final currentPeople = List<Person>.from(_peopleNotifier.value);
    final index = currentPeople.indexWhere((p) => p.id == userId);
    if (index != -1) {
      final person = currentPeople[index];
      final isConnected = person.connectionStatus == 'connected' || person.connectionStatus == 'ACCEPTED';
      final newStatus = isConnected ? 'none' : 'pending';
      currentPeople[index] = person.copyWith(connectionStatus: newStatus);
      _peopleNotifier.value = currentPeople;
      notifyListeners();

      try {
        final response = await ApiClient.instance.post('connections/$userId');
        if (response is Map && response['status'] != null) {
          final serverStatus = response['status'].toString();
          final updatedPeople = List<Person>.from(_peopleNotifier.value);
          final uIdx = updatedPeople.indexWhere((p) => p.id == userId);
          if (uIdx != -1) {
            updatedPeople[uIdx] = updatedPeople[uIdx].copyWith(connectionStatus: serverStatus);
            _peopleNotifier.value = updatedPeople;
            notifyListeners();
          }
        }
        return true;
      } catch (e) {
        debugPrint('[ConnectRepository] Toggle connect sync: $e');
        return true;
      }
    }
    return false;
  }

  /// Toggles group membership via POST /api/v1/groups/{groupId}/join.
  Future<bool> toggleJoinGroup(String groupId) async {
    final currentGroups = List<Group>.from(_groupsNotifier.value);
    final index = currentGroups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = currentGroups[index];
      final isJoined = group.isJoinedByCurrentUser;
      currentGroups[index] = group.copyWith(
        isJoinedByCurrentUser: !isJoined,
        membersCount: !isJoined ? group.membersCount + 1 : (group.membersCount - 1).clamp(0, 999999),
      );
      _groupsNotifier.value = currentGroups;
      notifyListeners();

      try {
        await ApiClient.instance.post('groups/$groupId/join');
        return true;
      } catch (e) {
        debugPrint('[ConnectRepository] Toggle group membership: $e');
        return true;
      }
    }
    return false;
  }

  /// Toggles mentorship request via POST /api/v1/mentors/{mentorId}/request.
  Future<bool> requestMentor(String mentorId, {String? note}) async {
    final currentMentors = List<Mentor>.from(_mentorsNotifier.value);
    final index = currentMentors.indexWhere((m) => m.id == mentorId);
    if (index != -1) {
      final mentor = currentMentors[index];
      final hasRequested = mentor.hasRequested;
      currentMentors[index] = mentor.copyWith(
        isRequestedByCurrentUser: !hasRequested,
        hasRequested: !hasRequested,
      );
      _mentorsNotifier.value = currentMentors;
      notifyListeners();

      try {
        final payload = note != null && note.isNotEmpty ? {'note': note} : null;
        await ApiClient.instance.post('mentors/$mentorId/request', body: payload);
        return true;
      } catch (e) {
        debugPrint('[ConnectRepository] Request mentor error: $e');
        return true;
      }
    }
    return false;
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

  /// Resets connection state on logout.
  void reset() {
    _peopleNotifier.value = [];
    _groupsNotifier.value = [];
    _mentorsNotifier.value = [];
    notifyListeners();
  }
}
