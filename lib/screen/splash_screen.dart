import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Logo scales from 0.2 (small) to 1.0 (full size)
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for animation to complete
    await _controller.forward();
    
    if (!mounted) return;

    try {
      // Check if user is logged in and has a valid token
      final isLoggedIn = await StorageService.isLoggedIn();
      final token = await StorageService.getToken();
      final userId = await StorageService.getUserId();

      print('🔍 Splash Screen - Checking login status...');
      print('   Is Logged In: $isLoggedIn');
      print('   Token exists: ${token != null && token.isNotEmpty}');
      print('   User ID: $userId');

      // If user is logged in and has a valid token and user ID, navigate to home
      if (isLoggedIn && 
          token != null && 
          token.isNotEmpty && 
          userId != null && 
          userId.isNotEmpty &&
          userId != '000000000000000000000000') {
        print('✅ User is logged in, navigating to home');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        print('⚠️ User not logged in, navigating to onboarding');
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } catch (e) {
      print('❌ Error checking login status: $e');
      // On error, go to onboarding (safe default)
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Transform.scale(
                scale: _logoScale.value,
                child: Image.asset(
                  'assets/images/hunt_property_logo_-removebg-preview.png',
                  fit: BoxFit.contain,
                  width: size.width * 0.9,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: size.width * 0.9,
                      height: size.width * 0.9,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.home,
                        size: 80,
                        color: AppColors.primaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}




