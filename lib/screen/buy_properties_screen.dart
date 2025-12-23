import 'package:flutter/material.dart';

class BuyPropertiesScreen extends StatefulWidget {
  const BuyPropertiesScreen({super.key});

  @override
  State<BuyPropertiesScreen> createState() => _BuyPropertiesScreenState();
}

class _BuyPropertiesScreenState extends State<BuyPropertiesScreen> {
  // Sample buy properties data
  List<Map<String, dynamic>> buyProperties = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'Luxury Villa in Premium Location',
      'location': 'Anna Nagar',
      'type': 'Freehold',
      'area': '2,500 Sq Ft',
      'bedrooms': 4,
      'bathrooms': 3,
      'hasOpenKitchen': true,
      'hasLoungeArea': true,
      'hasBalcony': true,
      'hasGymAccess': true,
      'price': '45,00,000',
      'date': '18 November 2024',
      'isFavorite': true,
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': 'Modern Apartment with Pool',
      'location': 'T Nagar',
      'type': 'Freehold',
      'area': '1,800 Sq Ft',
      'bedrooms': 3,
      'bathrooms': 2,
      'hasOpenKitchen': true,
      'hasLoungeArea': true,
      'hasBalcony': true,
      'hasGymAccess': true,
      'price': '32,50,000',
      'date': '12 November 2024',
      'isFavorite': true,
    },
    {
      'image': 'assets/images/onboarding3.png',
      'title': 'Spacious Family Home',
      'location': 'Velachery',
      'type': 'Freehold',
      'area': '1,500 Sq Ft',
      'bedrooms': 3,
      'bathrooms': 2,
      'hasOpenKitchen': false,
      'hasLoungeArea': true,
      'hasBalcony': false,
      'hasGymAccess': false,
      'price': '28,00,000',
      'date': '05 November 2024',
      'isFavorite': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
        title: const Text(
          'Shortlist',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search your shortlist',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Property List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: buyProperties.length,
              itemBuilder: (context, index) {
                return _buildPropertyCard(buyProperties[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFF5F5F5),
              child: Image.asset(
                property['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFFFF3E0),
                    child: const Center(
                      child: Icon(
                        Icons.home_work_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Property Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with heart icon
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (property['isFavorite']) {
                          _showRemoveDialog(property);
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2FED9A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location, Type, Area
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      property['location'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.grey[400]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        property['type'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      property['area'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Amenities
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildAmenityChip(
                      Icons.bed_outlined,
                      '${property['bedrooms']} Bedrooms',
                    ),
                    _buildAmenityChip(
                      Icons.bathtub_outlined,
                      '${property['bathrooms']} Bathroom',
                    ),
                    if (property['hasOpenKitchen'])
                      _buildAmenityChip(
                        Icons.kitchen_outlined,
                        'Open Kitchen',
                      ),
                    if (property['hasLoungeArea'])
                      _buildAmenityChip(
                        Icons.chair_outlined,
                        'Lounge Area',
                      ),
                    if (property['hasBalcony'])
                      _buildAmenityChip(
                        Icons.balcony_outlined,
                        'Balcony',
                      ),
                    if (property['hasGymAccess'])
                      _buildAmenityChip(
                        Icons.fitness_center_outlined,
                        'Gym Access',
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Price and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹ ${property['price']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      property['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Show remove from shortlist bottom sheet
// Show remove from shortlist bottom sheet
  void _showRemoveDialog(Map<String, dynamic> property) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ▓▓ Top indicator bar ▓▓
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // ▓▓ Title ▓▓
              const Text(
                'Remove from Shortlist?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // ▓▓ Property Card Preview ▓▓
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFFFFF3E0),
                        child: Image.asset(
                          property['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.home, size: 40, color: Colors.grey);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ▓▓ Text Details ▓▓
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  property['title'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.favorite, color: Color(0xFF2FED9A), size: 22),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  property['location'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "${property['area']}  ${property['type']}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),

                          const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              property['date'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          RichText(
                            textAlign: TextAlign.right,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '₹ ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                TextSpan(
                                  text: '${property['price']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '/month',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )

                      ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ▓▓ Buttons Row ▓▓
              Row(
                children: [
                  // ▓▓ CANCEL (white pill) ▓▓
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ▓▓ YES REMOVE (green pill) ▓▓
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          buyProperties.removeWhere(
                                (item) => item['title'] == property['title'],
                          );
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Property removed from shortlist'),
                            backgroundColor: Color(0xFF2FED9A),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2FED9A),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Yes, Remove",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }
}

