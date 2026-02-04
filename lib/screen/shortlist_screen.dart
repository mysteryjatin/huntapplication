import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/shortlist_cubit.dart';
import 'package:hunt_property/screen/rent_properties_screen.dart';
import 'package:hunt_property/screen/buy_properties_screen.dart';
import 'package:hunt_property/services/shortlist_service.dart';

class ShortlistScreen extends StatefulWidget {
  const ShortlistScreen({super.key});

  @override
  State<ShortlistScreen> createState() => _ShortlistScreenState();
}

class _ShortlistScreenState extends State<ShortlistScreen> {
  // Sample property data for RENT section
  final List<Map<String, dynamic>> rentProperties = [
    {
      'image': 'assets/images/onboarding1.png',
      'color': const Color(0xFFE3F2FD),
    },
    {
      'image': 'assets/images/onboarding2.png',
      'color': const Color(0xFFFCE4EC),
    },
    {
      'image': 'assets/images/onboarding3.png',
      'color': const Color(0xFFF3E5F5),
    },
    {
      'image': 'assets/images/login.png',
      'color': const Color(0xFFE8F5E9),
    },
  ];

  // Sample property data for BUY section
  final List<Map<String, dynamic>> buyProperties = [
    {
      'image': 'assets/images/onboarding1.png',
      'color': const Color(0xFFFFF3E0),
    },
    {
      'image': 'assets/images/onboarding2.png',
      'color': const Color(0xFFE0F2F1),
    },
    {
      'image': 'assets/images/onboarding3.png',
      'color': const Color(0xFFFFF9C4),
    },
    {
      'image': 'assets/images/login.png',
      'color': const Color(0xFFE1F5FE),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header with back button and title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Go back to home when back button is tapped
                    // This won't do anything since we're in bottom nav
                    // but kept for consistency with design
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Shortlist',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20), // Balance the back button
              ],
            ),
          ),

          // Search Bar
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: const Color(0xFFF5F5F5),
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: TextField(
          //       decoration: InputDecoration(
          //         hintText: 'Search your shortlist',
          //         hintStyle: TextStyle(
          //           color: Colors.grey[400],
          //           fontSize: 14,
          //         ),
          //         prefixIcon: Icon(
          //           Icons.search,
          //           color: Colors.grey[400],
          //           size: 22,
          //         ),
          //         border: InputBorder.none,
          //         contentPadding: const EdgeInsets.symmetric(
          //           horizontal: 16,
          //           vertical: 14,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          // Content area with RENT and BUY sections SIDE BY SIDE
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    // RENT and BUY sections in a Row (side by side)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // RENT Section (Left side)
                        Expanded(
                          child: _buildPropertySection(
                            title: 'RENT',
                            properties: rentProperties,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // BUY Section (Right side)
                        Expanded(
                          child: _buildPropertySection(
                            title: 'BUY',
                            properties: buyProperties,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build each property section (RENT or BUY)
  Widget _buildPropertySection({
    required String title,
    required List<Map<String, dynamic>> properties,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to respective screen based on title
        if (title == 'RENT') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => ShortlistCubit(
                  ShortlistService(),
                  transactionType: 'rent',
                )..load(),
                child: const RentPropertiesScreen(),
              ),
            ),
          );
        } else if (title == 'BUY') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => ShortlistCubit(
                  ShortlistService(),
                  transactionType: 'sale',
                )..load(),
                child: const BuyPropertiesScreen(),
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2x2 Grid of Property Images
            AspectRatio(
              aspectRatio: 1.0, // Square container
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return _buildPropertyImage(
                    properties[index]['image'],
                    properties[index]['color'],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Section Title BELOW the images
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build individual property image
  Widget _buildPropertyImage(String imagePath, Color fallbackColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: fallbackColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Show colored container with icon if image fails to load
            return Container(
              color: fallbackColor,
              child: Center(
                child: Icon(
                  Icons.home_work_outlined,
                  size: 32,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

