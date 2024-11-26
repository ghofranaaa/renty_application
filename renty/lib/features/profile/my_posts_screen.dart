import 'package:flutter/material.dart';
import 'package:renty/shared/main_scaffold.dart';
import 'package:renty/services/user_posts_service.dart';
import 'package:renty/models/post.dart';
import 'post_details_screen.dart';

class MyPostsScreen extends StatefulWidget {
  final String userId;

  const MyPostsScreen({super.key, required this.userId});

  @override
  _MyPostsScreenState createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  late Future<List<Post>> _userPosts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userPosts = _loadUserPosts();
  }

  // Modified to properly handle the Future
  Future<List<Post>> _loadUserPosts() async {
    if (!mounted) return [];

    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await UserPostsService.getUserPosts(widget.userId);
      return posts;
    } catch (error) {
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Separate refresh handler
  Future<void> _handleRefresh() async {
    setState(() {
      _userPosts = _loadUserPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Scaffold(
        body: Container(
          color: const Color(0xFFf8f2ea),
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              slivers: [
                // Header section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                            height: 50,
                            width: 50,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Keep Track!',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF303030),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Content section
                SliverToBoxAdapter(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FutureBuilder<List<Post>>(
                    future: _userPosts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Error loading posts: ${snapshot.error}'),
                                ElevatedButton(
                                  onPressed: _handleRefresh,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: Text('No posts found')),
                        );
                      }

                      final posts = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 18.0,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailsScreen(post: post),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    // Display post image
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                          image: (post.image != null && post.image!.isNotEmpty)
                                              ? DecorationImage(
                                            image: NetworkImage(
                                              'http://10.0.2.2:5000/uploads/${post.image}',
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                              : null,
                                          color: (post.image == null || post.image!.isEmpty)
                                              ? Colors.grey[200]
                                              : null,
                                        ),
                                        child: (post.image == null || post.image!.isEmpty)
                                            ? const Center(
                                          child: Icon(
                                            Icons.camera_alt_outlined,
                                            size: 50,
                                            color: Color(0xFF51abb2),
                                          ),
                                        )
                                            : null,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.title[0].toUpperCase() + post.title.substring(1),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 7),
                                            Text(
                                              'Status: ${post.status}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF303030),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Price: \$${post.price}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}