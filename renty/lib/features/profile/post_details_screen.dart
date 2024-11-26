import 'package:flutter/material.dart';
import 'package:renty/models/post.dart';
import 'package:renty/services/auth_helper.dart';
import 'package:renty/services/user_posts_service.dart';

import 'edit_post_screen.dart';

class PostDetailsScreen extends StatefulWidget {
  final Post post;

  const PostDetailsScreen({super.key, required this.post});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  bool isOwner = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    final currentUserId = await AuthenService.getCurrentUserId();
    if (mounted) {
      setState(() {
        isOwner = currentUserId == widget.post.userId;
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF51abb2),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerActions() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditPostScreen(post: widget.post),
                  ),
                );
              },
              icon: const Icon(
                Icons.edit,
                color: Color(0xFF00712d),
              ),
              label: const Text(
                'Edit',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _showDeleteConfirmation,
              icon: const Icon(
                Icons.delete,
                color: Color(0xFF00712d),
              ),
              label: const Text(
                'Delete',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() {
      isLoading = true;
    });

    try {
      final success = await UserPostsService.deletePost(widget.post.id);
      if (mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Return to previous screen
          Navigator.of(context).pop(true); // true indicates successful deletion
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete post'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (BuildContext context) {
        return PopScope(
          canPop: !isLoading, // Prevent popping when loading
          child: AlertDialog(
            title: const Text('Delete Post'),
            content: isLoading
                ? const Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Deleting post...'),
              ],
            )
                : const Text(
              'Are you sure you want to delete this post? This action cannot be undone.',
            ),
            actions: isLoading
                ? null
                : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _handleDelete(); // Call the delete function
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFFF9100)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf8f2ea), // Example: Light grey background
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Color(0xFFf8f2ea),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: const Color(0xFF51abb2),
                  width: 3.0, // Adjust width as needed
                ),
                image: (widget.post.image != null && widget.post.image!.isNotEmpty)
                    ? DecorationImage(
                  image: NetworkImage('http://10.0.2.2:5000/uploads/${widget.post.image}'),
                  fit: BoxFit.cover,
                )
                    : null,
                color: (widget.post.image == null || widget.post.image!.isEmpty)
                    ? Colors.transparent
                    : null,
              ),
              child: (widget.post.image == null || widget.post.image!.isEmpty)
                  ? const Center(
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 50,
                  color: Color(0xFF51abb2),
                ),
              )
                  : null,
            ),

            if (isOwner) _buildOwnerActions(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '\$${widget.post.price}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00712d),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status and Type Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              _buildInfoRow('Status', widget.post.status.toString().split('.').last),
                              _buildInfoRow('Type', widget.post.instrumentType.toString().split('.').last),
                              _buildInfoRow('Brand', widget.post.brand),
                              _buildInfoRow('Availability', widget.post.availability.toString().split('.').last),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Section
                  Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.post.description ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Information Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              _buildInfoRow('Phone', widget.post.phoneNumber),
                              _buildInfoRow('Location', widget.post.location),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}