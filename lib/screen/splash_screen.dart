import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/cubit/auth_cubit.dart';
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
  bool _hasCheckedSession = false;

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

    // Check for existing session
    _checkSessionAndNavigate();
    
    // Start animation
    _controller.forward();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Wait a bit to ensure storage is initialized
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    try {
      // Check if user is logged in
      final isLoggedIn = await StorageService.isLoggedIn();
      final userId = await StorageService.getUserId();
      
      // Ensure we have valid session data
      final hasValidSession = isLoggedIn && 
                             userId != null && 
                             userId.isNotEmpty && 
                             userId != '000000000000000000000000';
      
      _hasCheckedSession = true;
      
      // Wait for animation to complete (or minimum 2 seconds)
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (!mounted) return;
      
      if (hasValidSession) {
        // User is logged in, navigate to home
        print('✅ Session found - Navigating to home');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // No session, navigate to onboarding
        print('ℹ️ No session - Navigating to onboarding');
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } catch (e) {
      print('❌ Error checking session: $e');
      // On error, navigate to onboarding
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




