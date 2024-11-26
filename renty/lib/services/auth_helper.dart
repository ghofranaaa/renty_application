import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenService {
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  // Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      if (kDebugMode) {
        print("Retrieved token: $token");
      }
      return token;
    } catch (e) {
      debugPrint("Error retrieving token: $e");
      return null;
    }
  }

  // Get current user ID
  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(userIdKey);
      if (kDebugMode) {
        print("Retrieved userId: $userId");
      }
      return userId;
    } catch (e) {
      debugPrint("Error retrieving userId: $e");
      return null;
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(userIdKey);
    } catch (e) {
      debugPrint("Error logging out: $e");
    }
  }
}
