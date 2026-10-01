import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Isolated local persistence service.
class StorageService {
  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryCache = {};

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // In-memory fallback if native SharedPreferences is unavailable (e.g. tests)
      _prefs = null;
    }
  }

  Future<bool> setString(String key, String value) async {
    _memoryCache[key] = value;
    if (_prefs != null) {
      return await _prefs!.setString(key, value);
    }
    return true;
  }

  String? getString(String key) {
    if (_prefs != null) {
      return _prefs!.getString(key) ?? _memoryCache[key] as String?;
    }
    return _memoryCache[key] as String?;
  }

  Future<bool> setBool(String key, bool value) async {
    _memoryCache[key] = value;
    if (_prefs != null) {
      return await _prefs!.setBool(key, value);
    }
    return true;
  }

  bool? getBool(String key) {
    if (_prefs != null) {
      return _prefs!.getBool(key) ?? _memoryCache[key] as bool?;
    }
    return _memoryCache[key] as bool?;
  }

  Future<bool> setStringList(String key, List<String> value) async {
    _memoryCache[key] = value;
    if (_prefs != null) {
      return await _prefs!.setStringList(key, value);
    }
    return true;
  }

  List<String>? getStringList(String key) {
    if (_prefs != null) {
      return _prefs!.getStringList(key) ?? _memoryCache[key] as List<String>?;
    }
    return _memoryCache[key] as List<String>?;
  }

  Future<bool> setJson(String key, Map<String, dynamic> jsonMap) async {
    final encoded = jsonEncode(jsonMap);
    return await setString(key, encoded);
  }

  Map<String, dynamic>? getJson(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<bool> remove(String key) async {
    _memoryCache.remove(key);
    if (_prefs != null) {
      return await _prefs!.remove(key);
    }
    return true;
  }

  Future<bool> clear() async {
    _memoryCache.clear();
    if (_prefs != null) {
      return await _prefs!.clear();
    }
    return true;
  }
}
