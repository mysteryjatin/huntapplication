import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardData> _slides = const [
    _OnboardData(
      image: 'assets/images/onboarding1.png',
      title: 'Find Property',
      subtitle: 'Search thousands of verified properties in your area',
    ),
    _OnboardData(
      image: 'assets/images/onboarding2.png',
      title: 'Verified Listings',
      subtitle: 'All properties are verified by our expert team',
    ),
    _OnboardData(
      image: 'assets/images/onboarding3.png',
      title: 'Smart Filters',
      subtitle: 'Find exactly what you need with advanced filters',
    ),
  ];

  void _next() {
    if (_index < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('skip'),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _OnboardSlide(data: _slides[i]),
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: EdgeInsets.fromLTRB(
                32, 
                0, 
                32, 
                28 + MediaQuery.of(context).viewPadding.bottom
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Dots(count: _slides.length, index: _index),
                  FloatingActionButton(
                    heroTag: 'next',
                    shape: const CircleBorder(),
                    backgroundColor: AppColors.primaryColor,
                    onPressed: _next,
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String image;
  final String title;
  final String subtitle;
  const _OnboardData({required this.image, required this.title, required this.subtitle});
}

class _OnboardSlide extends StatelessWidget {
  final _OnboardData data;
  const _OnboardSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.06),
          // Image Container with fixed height
          SizedBox(
            height: screenHeight * 0.38,
            child: Center(
              child: Image.asset(
                data.image, 
                fit: BoxFit.contain,
                height: screenHeight * 0.35,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          // Title
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Text(
              data.title, 
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Subtitle
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Text(
              data.subtitle, 
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryColor : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}




