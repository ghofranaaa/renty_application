import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateAccountService {
  static final _client = http.Client();
  static const _baseUrl = 'http://10.0.2.2:5000'; // Update this to match your backend URL

  // Update user details
  static Future<Map<String, dynamic>> updateUserDetails({
    String? name,
    String? email,
    String? password,
    String? image, required String userId,
  }) async {
    try {
      // Retrieve the JWT token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token'); // Retrieve token (not userId)

      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await _client.put(
        Uri.parse('$_baseUrl/users/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // Use token for authentication
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'image': image,
        }),
      );

      final data = jsonDecode(response.body);

      // Handle response status codes
      switch (response.statusCode) {
        case 200:
          return {
            'success': true,
            'message': 'User updated successfully',
          };
        case 404:
          return {
            'success': false,
            'message': data['error'] ?? 'User not found'
          };
        case 500:
          return {
            'success': false,
            'message': data['error'] ?? 'An error occurred while updating user details'
          };
        default:
          return {
            'success': false,
            'message': data['error'] ?? 'Update failed'
          };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }
}
