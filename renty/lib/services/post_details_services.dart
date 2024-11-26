import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:renty/models/post.dart';  // Assuming Post is defined in post.dart
import 'package:renty/services/auth_helper.dart';  // Your AuthenService for token retrieval

class PostDetailsService {
  static Future<Post> fetchPostDetails(String postId) async {
    final token = await AuthenService.getToken(); // Retrieve the token from the AuthenService

    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/home/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',  // Add the Authorization header with the Bearer token
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Post.fromJson(data);  // Assuming Post.fromJson() is correctly implemented
    } else {
      throw Exception('Failed to load post details: ${response.statusCode}');
    }
  }
}
