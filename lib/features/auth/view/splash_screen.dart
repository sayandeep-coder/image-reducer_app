import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ripehash/app/constants/app_strings.dart';
import 'package:ripehash/app/routes/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Stay for 2-3 seconds as requested
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            const Icon(
              Icons.photo_filter,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            // App name
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}