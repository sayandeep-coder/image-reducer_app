import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ripehash/features/auth/view/login_screen.dart';
import 'package:ripehash/features/auth/view/splash_screen.dart';
import 'package:ripehash/features/home/view/home_screen.dart';

// App routes
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
}

// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);