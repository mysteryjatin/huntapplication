import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/my_listings_cubit.dart';
import 'package:hunt_property/models/my_listings_models.dart';
import 'package:hunt_property/services/my_listings_service.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:hunt_property/screen/widget/custombottomnavbar.dart';

class MyListingScreen extends StatefulWidget {
  const MyListingScreen({super.key});

  @override
  State<MyListingScreen> createState() => _MyListingScreenState();
}

class _MyListingScreenState extends State<MyListingScreen> {
  int _selectedTabIndex = 0;
  int _selectedNavIndex = 4; // Profile tab selected by default

  final List<String> _tabs = ['All', 'Active', 'Pending', 'Rejected'];
  late final MyListingsCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = MyListingsCubit(MyListingsService());
    _cubit.load(status: _statusForIndex(_selectedTabIndex));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      _cubit.loadMore();
    }
  }

  String _statusForIndex(int index) {
    switch (index) {
      case 1:
        return 'active';
      case 2:
        return 'pending';
      case 3:
        return 'rejected';
      case 0:
      default:
        return 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            // Custom App Bar
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'My Listing',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),

            // 🔥 Scrollable Tabs (No Overflow)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                height: 42,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      final isSelected = _selectedTabIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedTabIndex = index);
                          _cubit.load(status: _statusForIndex(index));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 16, right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Property List
            Expanded(
              child: BlocBuilder<MyListingsCubit, MyListingsState>(
                builder: (context, state) {
                  if (state is MyListingsLoading || state is MyListingsInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  if (state is MyListingsError) {
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

                  if (state is MyListingsLoaded && state.properties.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.home_work_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No listings found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MyListingsLoaded) {
                    final items = state.properties;
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          );
                        }
                        return PropertyCard(property: items[index]);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        // bottomNavigationBar: CustomBottomNavBar(
        //   selectedIndex: _selectedNavIndex,
        //   onItemSelected: (index) {
        //     setState(() => _selectedNavIndex = index);
        //   },
        // ),
      ),
    );
  }
}

//************* CARD UI ****************//

class PropertyCard extends StatelessWidget {
  final MyListingItem property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF2F9FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ⭐ IMAGE + ACTIVE BADGE
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[300],
                      child: Image.asset(
                        "assets/images/frame.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // ⭐ ACTIVE BADGE
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor, // bright green
                        borderRadius: BorderRadius.circular(6),
                      ),
                  child: Text(
                    _formatStatus(property.listingStatus),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black, // black text
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Content on Right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    Text(
                      '${property.address}${property.locality.isNotEmpty ? ', ${property.locality}' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _formatPrice(property.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Posted on ${_formatPostedDate(property.postedAt)}',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: Colors.grey[500],
              ),
            ),
          ),

          const SizedBox(height: 8),

          _viewsSavesBar(property.viewCount, property.saves),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.remove_red_eye_outlined,
                  label: 'View',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ActionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  iconColor: AppColors.redcolor,
                  textColor: AppColors.redcolor,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ActionButton(
                  icon: Icons.rocket_launch_outlined,
                  label: 'Boost',
                  backgroundColor: AppColors.primaryColor,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatPrice(num price) {
  if (price <= 0) return 'Price on request';
  final formatter = NumberFormat('#,##,##0');
  return '₹ ${formatter.format(price)}';
}

String _formatPostedDate(DateTime? date) {
  if (date == null) return '';
  return DateFormat('dd-MM-yyyy').format(date);
}

String _formatStatus(String status) {
  if (status.isEmpty) return '';
  final lower = status.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}



Widget _viewsSavesBar(int views, int saves) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F3FF), // light blue background
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        // 👁 VIEWS SECTION
        Row(
          children: [
            const Icon(
              Icons.remove_red_eye,
              size: 20,
              color: Color(0xFF1E73FF), // perfect blue
            ),
            const SizedBox(width: 6),

            Text(
              "$views",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),

            Text(
              "Views",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),

        const SizedBox(width: 26),

        // Divider |
        Container(
          height: 18,
          width: 1,
          color: Colors.grey[300],
        ),

        const SizedBox(width: 26),

        // 💚 SAVES SECTION
        Row(
          children: [
            const Icon(
              Icons.favorite_border,
              size: 20,
              color: Color(0xFF00CC88), // mint green
            ),
            const SizedBox(width: 6),

            Text(
              "$saves",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),

            Text(
              "Saves",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

//************* BUTTON WIDGET ****************//

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFE3F2FF),
          borderRadius: BorderRadius.circular(8),
          border: backgroundColor == null
              ? Border.all(color: const Color(0xFFE5E7EB), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: iconColor ?? Colors.black,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
