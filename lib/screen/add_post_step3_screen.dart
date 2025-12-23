import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/add_post_step4_screen.dart';

class AddPostStep3Screen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const AddPostStep3Screen({super.key, this.onBackPressed});

  @override
  State<AddPostStep3Screen> createState() => _AddPostStep3ScreenState();
}

class _AddPostStep3ScreenState extends State<AddPostStep3Screen> {
  final Set<String> _selectedAmenities = {};

  final List<Map<String, dynamic>> _amenities = [
    {'name': 'Car Parking', 'image': 'assets/images/car_parking.png'},
    {'name': 'Kid\'s Playground', 'image': 'assets/images/Kids.png'},
    {'name': 'Club House', 'image': 'assets/images/club_house.png'},
    {'name': 'Restaurants', 'image': 'assets/images/restro.png'},
    {'name': 'Fitness Gym', 'image': 'assets/images/gym.png'},
    {'name': 'School', 'image': 'assets/images/school.png'},
    {'name': 'Hospital', 'icon': Icons.local_hospital},
    {'name': 'Swimming Pool', 'icon': Icons.pool},
    {'name': '24 Hour Water Supply', 'icon': Icons.water_drop},
    {'name': 'Firefighting', 'icon': Icons.fire_extinguisher},
    {'name': 'Power backup', 'icon': Icons.power},
    {'name': 'Yoga', 'image': 'assets/images/yoga.png'},
    {'name': 'Library', 'image': 'assets/images/Library.png'},
  ];

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: widget.onBackPressed ?? () {},
        ),
        title: Column(
          children: [
            Text(
              'Amenities',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              'Step 3 of 4',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 24),
            onPressed: widget.onBackPressed ?? () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ------------------ AMENITIES WRAPPED IN BLUE BG ------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF7FF), // 🔵 SAME BLUE AS SCREENSHOT
                  borderRadius: BorderRadius.circular(24),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Amenities'),
                    const SizedBox(height: 20),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: _amenities.length,
                      itemBuilder: (context, index) {
                        final item = _amenities[index];
                        final isSelected = _selectedAmenities.contains(item['name']);

                        return _buildAmenityCard(
                          item['name'],
                          isSelected,
                          image: item['image'],
                          icon: item['icon'],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ------------------ PHOTOS SECTION ------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Photos',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddPostStep4Screen(
                            onBackPressed: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- UI COMPONENTS ----------------------

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityCard(
      String name,
      bool isSelected, {
        String? image,
        IconData? icon,
      }) {
    return GestureDetector(
      onTap: () => _toggleAmenity(name),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON BOX
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: image != null
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(image, fit: BoxFit.contain),
              )
                  : Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.black : Colors.grey[700],
              ),
            ),

            const SizedBox(height: 8),

            // TEXT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
