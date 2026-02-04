import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/shortlist_cubit.dart';
import 'package:hunt_property/models/property_models.dart';

class RentPropertiesScreen extends StatefulWidget {
  const RentPropertiesScreen({super.key});

  @override
  State<RentPropertiesScreen> createState() => _RentPropertiesScreenState();
}

class _RentPropertiesScreenState extends State<RentPropertiesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger pagination when user is close to bottom
    if (currentScroll >= maxScroll - 200) {
      context.read<ShortlistCubit>().loadMore();
    }
  }

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
            child: BlocBuilder<ShortlistCubit, ShortlistState>(
              builder: (context, state) {
                if (state is ShortlistLoading || state is ShortlistInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2FED9A),
                    ),
                  );
                }

                if (state is ShortlistError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  );
                }

                if (state is ShortlistLoaded &&
                    state.properties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/no_proerty_found.png",
                          width: 220,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No shortlisted rent properties",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ShortlistLoaded) {
                  final items = state.properties;
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount:
                        items.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        // Load-more indicator
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2FED9A),
                            ),
                          ),
                        );
                      }
                      return _buildPropertyCard(items[index]);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    final imageUrl = property.images.isNotEmpty
        ? property.images.first
        : 'assets/images/onboarding1.png';

    final priceText = property.price > 0 ? '₹ ${property.price}' : 'Price on request';

    final location =
        '${property.locality}${property.city.isNotEmpty ? ', ${property.city}' : ''}';

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
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE3F2FD),
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
                        property.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2FED9A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 18,
                        color: Colors.white,
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
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${property.areaSqft} Sq Ft',
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
                      '${property.bedrooms} Bedrooms',
                    ),
                    _buildAmenityChip(
                      Icons.bathtub_outlined,
                      '${property.bathrooms} Bathroom',
                    ),
                    if (property.attachedBalcony)
                      _buildAmenityChip(
                        Icons.balcony_outlined,
                        'Balcony',
                      ),
                    if (property.storeRoom)
                      _buildAmenityChip(
                        Icons.store_mall_directory_outlined,
                        'Store Room',
                      ),
                    if (property.servantRoom)
                      _buildAmenityChip(
                        Icons.meeting_room_outlined,
                        'Servant Room',
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Price
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
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
  void _showRemoveDialog(Map<String, dynamic> property) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── Indicator ───
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Remove from Shortlist?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black
                  ),
                ),

                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.grey[300]),
                const SizedBox(height: 20),

                // ─── Property Card ───
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F9FF), // 🔵 light blue bg
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🖼 Image
                      // ClipRRect(
                      //   borderRadius: const BorderRadius.all( Radius.circular(20)),
                      //   child: SizedBox(
                      //     width: 100,
                      //     height: 100,
                      //     child: Image.asset(
                      //       property['image'],
                      //       fit: BoxFit.fill,
                      //       errorBuilder: (_, __, ___) =>
                      //       const Icon(Icons.home, size: 42),
                      //     ),
                      //   ),
                      // ),
                      ClipRRect(
                  borderRadius: const BorderRadius.all( Radius.circular(20)),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Transform.translate(
                            offset: const Offset(0, -10), // ⬅️ upar push
                            child: Image.asset(
                              property['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // 📄 Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + Heart
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    property['title'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.favorite,
                                  color: Color(0xFF2FED9A),
                                  size: 22,
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Location
                            Text(
                              property['location'],
                              style: TextStyle(
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade700,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Area + Type
                            Text(
                              "${property['area']}  ${property['type']}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Date + Price
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    property['date'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '₹ ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      TextSpan(
                                        text: property['price'],
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ─── Buttons ───
                Row(
                  children: [
                    Expanded(
                      child: _pillButton(
                        text: "Cancel",
                        isPrimary: false,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _pillButton(
                        text: "Yes, Remove",
                        isPrimary: true,
                        onTap: () {
                          setState(() {
                            // rentProperties.removeWhere(
                            //       (e) => e['title'] == property['title'],
                            // );
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pillButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF2FED9A) : Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: isPrimary
              ? null
              : Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black
          ),
        ),
      ),
    );
  }
}
