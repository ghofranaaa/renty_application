// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:renty/services/auth_helper.dart';
import '../models/post.dart';

class CreatePostService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  // Create a new post
  static Future<Post> createPost({
    required String instrumentType,
    required String title,
    required String brand,
    required double price,
    String? description,
    required String phoneNumber,
    String? image,
    required String status,
    required String location,
  }) async {
    final token = await AuthenService
        .getToken(); // Assuming this method retrieves the token

    final url = Uri.parse('$baseUrl/posts/create');
    try {
      final Map<String, dynamic> body = {
        'instrument_type': instrumentType,
        'title': title,
        'brand': brand,
        'price': price,
        'description': description ?? '',
        'phone_number': phoneNumber,
        'status': status,
        'image': image ?? '', // Provide a default empty string if image is null
        'location': location,
      };


      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data); // Return the created post
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception('Failed to create post: $error');
      }
    } catch (error) {
      throw Exception('Error creating post: $error'); // Handle network errors
    }
  }


  // Fetch posts with pagination
  Future<List<Post>> getPosts({int page = 1}) async {
    try {
      final token = await AuthenService.getToken(); // Fetch the token

      if (token == null) {
        throw Exception('Authorization token is missing.');
      }

      final url = Uri.parse('$baseUrl/home/search?page=$page');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Post> posts = (data['posts'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
        return posts; // Return posts on success
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching posts: $error'); // Handle errors
    }
  }


  // Search posts by title
  Future<List<Post>> searchPosts(String query) async {
    final response = await http.get(
        Uri.parse('$baseUrl/home/posts/search?title=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> postList = json.decode(response.body);
      return postList.map((json) => Post.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return []; // No posts found
    } else {
      throw Exception('Failed to search posts');
    }
  }


  Future<List<Post>> getPostsByCategory(String query) async {
    final token = await AuthenService
        .getToken(); // Fetch the authorization token
    final url = Uri.parse('$baseUrl/home/category?type=$query');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          // Include the token in the request header
          'Content-Type': 'application/json',
          // Ensure content type is set
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((post) => Post.fromJson(post)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Check your token.');
      } else {
        throw Exception('Failed to load posts for category: $query');
      }
    } catch (e) {
      throw Exception('Error fetching posts by category: $e');
    }
  }
}