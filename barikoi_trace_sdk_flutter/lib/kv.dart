import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _userIdKey = 'userId';
  static const String _tripIdKey = 'tripId';

  // Singleton pattern
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();
  SharedPreferences? _prefs;

  SharedPreferencesService._internal();

  factory SharedPreferencesService() {
    return _instance;
  }

  // Initialize SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set userId
  Future<void> setUserId(String userId) async {
    await _prefs?.setString(_userIdKey, userId);
  }

  // Get userId
  String? getUserId() {
    return _prefs?.getString(_userIdKey);
  }

  // Set tripId
  Future<void> setTripId(String tripId) async {
    await _prefs?.setString(_tripIdKey, tripId);
  }

  // Get tripId
  String? getTripId() {
    return _prefs?.getString(_tripIdKey);
  }

  // Clear userId and tripId
  Future<void> clearData() async {
    await _prefs?.remove(_userIdKey);
    await _prefs?.remove(_tripIdKey);
  }
}
