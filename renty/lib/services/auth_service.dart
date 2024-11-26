import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final _client = http.Client();
  static const _baseUrl = 'http://10.0.2.2:5000/home';


  // Login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Parse the JSON response
      final data = jsonDecode(response.body);

      // Handle response status codes
      switch (response.statusCode) {
        case 200:
        // Save the access token and user id to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['access_token']);
          await prefs.setString('user_id', data['user_id']);  // Save user_id as well

          return {
            'success': true,
            'access_token': data['access_token'],
            'user_id': data['user_id'], // Include user_id in response
            'message': 'Login successful'
          };
        case 401:
          return {
            'success': false,
            'message': data['message'] ?? 'Invalid credentials'
          };
        case 404:
          return {
            'success': false,
            'message': data['message'] ?? 'User not found'
          };
        default:
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed'
          };
      }
    } catch (e) {
      // Improved error handling message
      return {
        'success': false,
        'message': e.toString(),
        'error': e.toString()  // Optional: include the actual error message for debugging
      };
    }
  }

  // Register method (optional)
  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/register'), // Fix the URL to use the correct endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      switch (response.statusCode) {
        case 201:
          return {
            'success': true,
            'message': data['message'] ?? 'Registration successful'
          };
        case 400:
          return {
            'success': false,
            'message': data['message'] ?? 'Invalid registration details'
          };
        default:
          return {
            'success': false,
            'message': data['message'] ?? 'Registration failed'
          };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred during registration. Please try again.',
        'error': e.toString()  // Optional: for debugging during development
      };
    }
  }
}
