import 'package:flutter/material.dart';
import 'package:renty/features/profile/my_posts_screen.dart';
import 'package:renty/shared/main_scaffold.dart';
import 'package:renty/services/auth_helper.dart';
import 'account_details.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final currentUserId = await AuthenService.getCurrentUserId();
      setState(() {
        userId = currentUserId;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error appropriately
      debugPrint('Error loading user ID: $e');
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await AuthenService.logout();
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/welcome'); // Adjust route as needed
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
    }
  }

  Future<void> _navigateToMyPosts(BuildContext context) async {
    if (isLoading) {
      // Prevent navigation while loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loading user data... Please wait.')),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load user data. Please try again.')),
      );
      return;
    }

    try {
      // Verify token before navigation
      final token = await AuthenService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again')),
        );
        _handleLogout(context);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyPostsScreen(userId: userId!)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _navigateToAccountDetails(BuildContext context) async {
    if (isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loading user data... Please wait.')),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load user data. Please try again.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyAccountScreen(userId: userId!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return MainScaffold(
      child: Scaffold(
        backgroundColor: const Color(0xFFf8f2ea),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: AppBar(
            backgroundColor: const Color(0xFFf8f2ea),
            elevation: 0,
            flexibleSpace: Stack(
              children: [
                Positioned(
                  top: 8.0,
                  left: 16.0,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      height: 50,
                      width: 50,
                    ),
                  ),
                ),
                Positioned(
                  top: 15.0,
                  left: 80.0, // Adjust this value to position text next to the logo
                  child: Text(
                    'My Space', // Your desired text
                    style: TextStyle(
                      color: Colors.black87, // Adjust color as needed
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 120),
          child: Column(
            children: [
              const SizedBox(height: 70),
              ProfileMenu(
                text: "My Account",
                icon: Icons.account_circle_outlined,
                press: () => _navigateToAccountDetails(context),
              ),
              ProfileMenu(
                text: "My Posts",
                icon: Icons.pageview_outlined,
                press: () => _navigateToMyPosts(context),
              ),
              ProfileMenu(
                text: "Log Out",
                icon: Icons.logout_rounded,
                press: () => _handleLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.text,
    required this.icon,
    this.press,
  });

  final String text;
  final IconData icon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFF7643),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: press,
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF7643),
              size: 22,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF757575),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF757575),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
