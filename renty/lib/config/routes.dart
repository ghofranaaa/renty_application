// config/routes.dart
import 'package:flutter/material.dart';
import '../features/profile/my_posts_screen.dart';
import '../splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/welcome_screen.dart';
import '../features/profile/login.dart';
import '../features/profile/sign_up.dart';
import '../features/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String search = '/search';
  static const String posts = '/posts';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
    home: (context) => HomeScreen(onPostCreated: (bool success) {  },),
    search: (context) => HomeScreen(
      onPostCreated: (bool success) {  },
      showSearch: true),
    posts: (context) => const MyPostsScreen(userId: '',),
    profile: (context) => const ProfileScreen(),
  };
}