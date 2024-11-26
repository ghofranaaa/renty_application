// lib/services/user_posts_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:renty/models/post.dart';
import 'package:renty/services/auth_helper.dart';

class UserPostsService {
  static const String baseUrl = 'http://10.0.2.2:5000'; // Update this with your API URL

  // Get posts for a specific user
  static Future<List<Post>> getUserPosts(String userId) async {
    try {
      // Get the authentication token
      String? token = await AuthenService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/users/user/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // No posts found
        return [];
      } else if (response.statusCode == 401) {
        // Unauthorized - token might be expired
        throw Exception('Unauthorized access. Please login again.');
      } else {
        throw Exception(' to load user posts: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  static Future<bool> updatePost(Post updatedPost, {
    required String postId,
    String? instrumentType,
    String? title,
    String? brand,
    double? price,
    String? phoneNumber,
    String? description,
    String? image,
    String? status,
    String? location,
    String? availability,
  }) async {
    final token = await AuthenService.getToken(); // Retrieve the token

    final url = Uri.parse('$baseUrl/posts/posts/$postId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'instrument_type': instrumentType,
          'title': title,
          'brand': brand,
          'price': price,
          'phone_number': phoneNumber,
          'description': description,
          'image': image,
          'status': status,
          'location': location,
          'availability': availability,
        }
          ..removeWhere((key, value) => value == null)), // Remove null values
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Post updated successfully');
        }
        return true; // Added explicit return true for success
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception('Failed to update post: $error');
      }
    } catch (error) {
      throw Exception('Error updating post: $error'); // Handle network errors
    }
  }
  // Delete a post
  static Future<bool> deletePost(String postId) async {
    final token = await AuthenService.getToken();

    final url = Uri.parse('$baseUrl/posts/posts/$postId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Post deleted successfully');
        }
        return true; // Post deleted successfully
      } else if (response.statusCode == 404) {
        throw Exception('Post not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception('Failed to delete post: $error');
      }
    } catch (error) {
      throw Exception('Error deleting post: $error');
    }
  }
}