import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final String? tag;
  final String? price;
  final String? location;

  const PropertyDetailsScreen({
    super.key,
    this.tag,
    this.price,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image Section
            _buildPropertyImage(),
            // Price and Location Summary
            _buildPriceSection(),
            const SizedBox(height: 24),
            // Map Section
            _buildMapSection(),
            const SizedBox(height: 24),
            // Amenities Section
            _buildAmenitiesSection(),
            const SizedBox(height: 24),
            // Key Highlights Section
            _buildKeyHighlightsSection(),
            const SizedBox(height: 24),
            // Property Description Section
            _buildPropertyDescriptionSection(),
            const SizedBox(height: 24),
            // Add responsive bottom padding to prevent content from being hidden
            SizedBox(height: 80 + MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        // child: Container(
        //   decoration: const BoxDecoration(
        //     color: Color(0xFF00E676),
        //     shape: BoxShape.circle,
        //   ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
          ),
        ),

      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search City/Location/Project',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textLight),
            prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: AppColors.textDark),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.textDark),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPropertyImage() {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          color: AppColors.lightGray,
          child: Image.asset(
            'assets/images/onboarding1.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.home, size: 100, color: AppColors.primaryColor);
            },
          ),
        ),
        // Overlay gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),
        // Posted info
        Positioned(
          bottom: 12,
          left: 16,
          child: const Text(
            'Posted 2 days ago by owner',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        // Photos count
        Positioned(
          bottom: 12,
          right: 16,
          child: const Text(
            '3 Photos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            price ?? '₹ 45Lac',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Best Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'For ${tag ?? 'Sell'} in ${location ?? 'Hyderabad, Hyderabad City'}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'See Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Stack(
              children: [
                // Placeholder for map
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, size: 60, color: AppColors.textLight),
                      const SizedBox(height: 8),
                      Text(
                        location ?? 'Hyderabad',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                // Map pin
                const Positioned(
                  top: 80,
                  left: 120,
                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View on map',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = [
      {'image': 'assets/images/school.png', 'label': 'School'},
      {'image': 'assets/images/Library.png', 'label': 'Library'},
      {'image': 'assets/images/car_parking .png', 'label': 'Car Parking'},
      {'image': 'assets/images/Kids.png', 'label': "Kid's Playground"},
      {'image': 'assets/images/restro.png', 'label': 'Restaurants'},
      {'image': 'assets/images/club_house.png', 'label': 'Club House'},
      {'image': 'assets/images/gym.png', 'label': 'Fitness Gym'},
      {'image': 'assets/images/yoga .png', 'label': 'Yoga'},
    ];

    // Test if assets are accessible
    for (var amenity in amenities) {
      debugPrint('Checking asset: ${amenity['image']}');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amenities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Reduced to give more vertical space
            ),
            itemCount: amenities.length,
            itemBuilder: (context, index) {
              final amenity = amenities[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderGray),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _buildAmenityImage(amenity['image'] as String),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6), // Reduced spacing
                  Flexible(
                    child: Text(
                      amenity['label'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeyHighlightsSection() {
    final highlights = [
      {'label': 'Bedrooms', 'value': '-'},
      {'label': 'Bathrooms', 'value': '2'},
      {'label': 'Balcony', 'value': '1'},
      {'label': 'Store Room', 'value': 'No'},
      {'label': 'Covered area', 'value': '-'},
      {'label': 'Carpet area', 'value': '937 Sq ft'},
      {'label': 'Flat area', 'value': '-'},
      {'label': 'Status', 'value': '-'},
      {'label': 'Transaction type', 'value': 'Resale'},
      {'label': 'Floor', 'value': '2 (Out of 5 Floors)'},
      {'label': 'Car Parking', 'value': 'yes'},
      {'label': 'Furnished Status', 'value': '-'},
      {'label': 'Lift', 'value': 'yes'},
      {'label': 'Type of Ownership', 'value': 'Leasehold'},
      {'label': 'Facing', 'value': '-'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Highlight',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...highlights.map((highlight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        highlight['label']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        highlight['value']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPropertyDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Property Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildDescriptionItem('Description', 'Located at prime location of Noida'),
          _buildDescriptionItem('Property For', tag ?? 'Sell'),
          _buildDescriptionItem('State', 'Uttar Pradesh'),
          _buildDescriptionItem('City', 'Gautam Buddha Nagar'),
          _buildDescriptionItem('Locality', 'Sector 104'),
          _buildDescriptionItem('Address', 'Sector 100'),
          _buildDescriptionItem('Landmark', 'Near Pathways School'),
          _buildDescriptionItem('Bedrooms', '4'),
          _buildDescriptionItem('Bathrooms', '4'),
          _buildDescriptionItem('Balconies', '5'),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),

      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.1),
      //       blurRadius: 10,
      //       offset: const Offset(0, -2),
      //     ),
      //   ],
      // ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Get Phone No',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Contact Owner',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      width: 44,
      height: 44,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌❌❌ FAILED TO LOAD: $imagePath');
        debugPrint('Error type: ${error.runtimeType}');
        debugPrint('Error: $error');
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.broken_image,
            color: AppColors.primaryColor,
            size: 24,
          ),
        );
      },
    );
  }
}

