import 'package:flutter/material.dart';
import 'package:renty/features/home/home_screen.dart';
import '../config/routes.dart';
import 'package:renty/features/profile/post_creation_screen.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final bool showNavBar;

  const MainScaffold({
    super.key,
    required this.child,
    this.showNavBar = true,
  });

  @override
  Widget build(BuildContext context) {
    String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: child),
          if (showNavBar)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Make the background slightly transparent
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BottomNavigationBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      currentIndex: _getCurrentIndex(currentRoute),
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: Colors.orange,
                      unselectedItemColor: Colors.grey,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.search),
                          label: 'Search',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.add),
                          label: 'Add',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person_2_outlined),
                          label: 'Profile',
                        ),
                      ],
                      onTap: (index) {
                        switch (index) {
                          case 0:
                            Navigator.pushNamed(context, AppRoutes.home);
                            break;
                          case 1:
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                  onPostCreated: (bool success) {},
                                  showSearch: true,
                                ),
                              ),
                            );
                            break;
                          case 2:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostCreationScreen(
                                  onPostCreated: (bool success) {},
                                ),
                              ),
                            );
                            break;
                          case 3:
                            Navigator.pushNamed(context, AppRoutes.profile);
                            break;
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getCurrentIndex(String routeName) {
    switch (routeName) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.search:
        return 1;
      case AppRoutes.posts:
        return 2;
      case AppRoutes.profile:
        return 3;
      default:
        return 0;
    }
  }
}
