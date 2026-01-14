// home_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hunt_property/screen/add_post_screen.dart';
import 'package:hunt_property/screen/blog_detail_screen.dart';
import 'package:hunt_property/screen/profile_screen.dart';
import 'package:hunt_property/screen/search_screen.dart';
import 'package:hunt_property/screen/shortlist_screen.dart';
import 'package:hunt_property/screen/side_menu_screen.dart';
import 'package:hunt_property/screen/spin_popup_screen.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/property_service.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/models/property_models.dart';
import 'filter_screen.dart';
import 'widget/custombottomnavbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  int _selectedCategoryIndex = 0;
  int _carouselPage = 0;
  bool _isSearchFocused = false;

  final PageController _carouselController = PageController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PropertyService _propertyService = PropertyService();
  List<Property> _properties = [];
  bool _isLoadingProperties = false;
  final categories = [
    'Buy',
    'Rent',
    'Projects',
    'Residential',
    'Commercial',
    'Agents',
  ];
  // Sample data (move to models / API later)
  final List<Map<String, String>> _topSelling = [
    {
      'tag': 'Sell',
      'title': 'Best Location',
      'price': '₹45L',
      'location': 'Anna Nagar, Chennai'
    },
    {
      'tag': 'Sell',
      'title': 'Best Location',
      'price': '₹45L',
      'location': 'Anna Nagar, Chennai'
    },
  ];

  final List<Map<String, String>> _recommended = [
    {
      'tag': 'Sell',
      'title': 'Best Location',
      'price': '₹55L',
      'location': 'Anna Nagar, Chennai'
    },
    {
      'tag': 'Sell',
      'title': 'Best Location',
      'price': '₹55L',
      'location': 'Anna Nagar, Chennai'
    },
  ];

  final List<Map<String, String>> _rents = [
    {
      'tag': 'Rent',
      'title': 'Fully furnished flat',
      'price': '₹15,000',
      'location': '3BHK | Anna Nagar, Chen...'
    },
    {
      'tag': 'Rent',
      'title': 'Fully furnished flat',
      'price': '₹15,000',
      'location': '3BHK | Anna Nagar, Chen...'
    },
  ];

  final List<Map<String, String>> _services = [
    {'asset': 'assets/images/home_loan.png', 'label': 'Home Loan'},
    {'asset': 'assets/images/property_worth_calculator.png', 'label': 'Property Worth\nCalculator'},
    {'asset': 'assets/images/vaastu_calculator.png', 'label': 'Vastu\nCalculator'},
    {'asset': 'assets/images/sellrentadpackages.png', 'label': 'Sell / Rent Ad\nPackages'},
    {'asset': 'assets/images/channel_partner.png', 'label': 'Channel\nPartner'},
    {'asset': 'assets/images/legal_advisory.png', 'label': 'Legal\nAdvisory'},
    {'asset': 'assets/images/nri_center.png', 'label': 'NRI\nCenter'},
    {'asset': 'assets/images/rera_service.png', 'label': 'RERA\nService'},
  ];



  final List<Map<String, dynamic>> _blogs = [
    {
      'title': 'Noida Seals Major Housing Projects Due to Violation...',
      'image': 'assets/images/noidasale.png',
      'bg': const Color(0xFFFFA726)
    },
    {
      'title': 'YEDA Unveils Mega Plot Scheme Near Delhi...',
      'image': 'assets/images/blog2.png',
      'bg': const Color(0xFF66BB6A)
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(
          () => setState(() => _isSearchFocused = _searchFocusNode.hasFocus),
    );

    _loadProperties();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Handle Add button click with spin popup check
  Future<void> _handleAddButtonClick() async {
    print('🔘 Add button clicked from bottom navigation');
    
    // Check if user has added any properties
    final userPropertiesCount = await _propertyService.getUserPropertiesCount();
    print('📊 User properties count: $userPropertiesCount');
    
    // Show spin popup ONLY if user has 0 properties (no flag check needed)
    if (userPropertiesCount == 0) {
      print('✅ User has 0 properties, showing spin popup');
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: const SpinPopupScreen(),
          ),
        );
        print('✅ Spin popup bottom sheet shown');
        return; // Don't navigate to add post, let spin popup handle it
      }
    } else {
      print('⚠️ User has $userPropertiesCount properties, going directly to add post');
    }
    
    // If user has properties, go directly to add post
    if (mounted) {
      print('➡️ Navigating to add post screen');
      setState(() => selectedIndex = 2);
    }
  }

  // MAIN SCREEN SWITCHER
  Widget _buildMainScreen() {
    switch (selectedIndex) {
      case 1:
        return SearchScreen(onBackPressed: () => setState(() => selectedIndex = 0));
      case 2:
        return AddPostScreen(
          onBackPressed: () => setState(() => selectedIndex = 0),
        );
      case 3:
        return const ShortlistScreen();
      case 4:
        return ProfileScreen(onBackPressed: () => setState(() => selectedIndex = 0));
      default:
        return _homeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: _buildMainScreen(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onItemSelected: (i) async {
          // If Add button (index 2) is clicked, check for spin popup first
          if (i == 2) {
            await _handleAddButtonClick();
          } else {
            setState(() => selectedIndex = i);
          }
        },
      ),
    );
  }

  // DRAWER
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.grey[850],
      width: MediaQuery.of(context).size.width * 0.90,
      child: SideMenuScreen(
        onMenuItemSelected: (index) {
          setState(() => selectedIndex = index);
          Navigator.pop(context);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  // ----------------------------------------------------------
  // HOME CONTENT — wrapped in LayoutBuilder + Flexible to avoid micro-overflow
  // ----------------------------------------------------------
  Widget _homeContent() {
    return Column(
      children: [

        /// FIXED HEADER AREA
        _HeaderArea(
          scaffoldKey: _scaffoldKey,
          isSearchFocused: _isSearchFocused,
          searchController: _searchController,
          searchFocusNode: _searchFocusNode,
          onTuneTap: _openFilter,
        ),

        /// ALL CONTENT SCROLLS — NO OVERFLOW POSSIBLE
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 20),

                  _GetStartedCarousel(
                    controller: _carouselController,
                    onPageChanged: (i) => setState(() => _carouselPage = i),
                    pageIndex: _carouselPage,
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle("Latest Properties"),
                  if (_isLoadingProperties)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_properties.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'No properties found. Try adding one from "Post Your Property".',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    )
                  else
                    _HorizontalPropertyList.fromProperties(properties: _properties),

                  const SizedBox(height: 20),
                  _ServicesGrid(services: _services),

                  _sectionTitle("REAL ESTATE PROJECTS"),
                  _HorizontalProjectsList(),

                  const SizedBox(height: 20),
                  _BlogSection(
                    blogs: _blogs,
                    onViewBlog: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlogDetailScreen(
                          title: "Property Tips",
                          image: "assets/images/noidasale.png",
                          bgColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  _SellingRentingCard(
                    onPost: () async {
                      // Use the same logic as bottom nav Add button
                      await _handleAddButtonClick();
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  // simple section title
  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        t,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // footer
  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Text(
          "HuntProperty © 2025. All rights reserved.",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.5),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) =>
            FilterScreen(scrollController: scrollController),
      ),
    );
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoadingProperties = true;
    });
    final props = await _propertyService.getProperties();
    if (!mounted) return;
    setState(() {
      _properties = props;
      _isLoadingProperties = false;
    });
  }
}

// ------------------------
// Small widget: Header area (top bar + search + categories)
// ------------------------
class _HeaderArea extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isSearchFocused;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onTuneTap;

  const _HeaderArea({
    required this.scaffoldKey,
    required this.isSearchFocused,
    required this.searchController,
    required this.searchFocusNode,
    required this.onTuneTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF69F4B6), Color(0xFF5FD1B1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => scaffoldKey.currentState?.openDrawer(),
                    child: const Icon(Icons.menu, size: 30, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 100,
                    child: Image.asset(
                      'assets/images/hunt_property_logo_-removebg-preview.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          size: 26, color: Colors.black),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Text(
                            '0',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(40),
                  // ❌ border removed
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        cursorColor: AppColors.primaryColor,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Search your area, project",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onTuneTap,
                      child: const Icon(Icons.tune, color: Colors.grey, size: 20),
                    ),
                  ],
                ),
              ),
            ),


            // Categories
            SizedBox(
              height: 52,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(label: 'Buy', selected: true),
                  const SizedBox(width: 18),
                  _CategoryChip(label: 'Rent', selected: false),
                  const SizedBox(width: 18),
                  _CategoryChip(label: 'Projects', selected: false),
                  const SizedBox(width: 18),
                  _CategoryChip(label: 'Residential', selected: false),
                  const SizedBox(width: 18),
                  _CategoryChip(label: 'Commercial', selected: false),
                  const SizedBox(width: 18),
                  _CategoryChip(label: 'Agents', selected: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _CategoryChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // selection handled in parent if needed
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.black : Colors.black87,
            ),
          ),
          if (selected)
            Container(
              margin: const EdgeInsets.only(top: 6),
              height: 3,
              width: 32,
              color: Colors.black,
            ),
        ],
      ),
    );
  }
}

// ------------------------
// GET STARTED CAROUSEL
// ------------------------
class _GetStartedCarousel extends StatelessWidget {
  final PageController controller;
  final Function(int) onPageChanged;
  final int pageIndex;

  const _GetStartedCarousel({
    required this.controller,
    required this.onPageChanged,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Get Started with",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Find your ideal home with us",
                  style: TextStyle(fontSize: 14, color: AppColors.textLight)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: controller,
            itemCount: 3,
            onPageChanged: (i) => onPageChanged(i),
            itemBuilder: (context, i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.lightGray,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    "assets/images/onboarding${i + 1}.png",
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
                (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == pageIndex ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == pageIndex ? const Color(0xFF2FED9A) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        )
      ],
    );
  }
}

// ------------------------
// HORIZONTAL PROPERTY LIST (reusable widget)
// ------------------------
class _HorizontalPropertyList extends StatelessWidget {
  final List<Map<String, String>>? properties;
  final List<Property>? apiProperties;

  const _HorizontalPropertyList({
    this.properties,
    this.apiProperties,
  });

  factory _HorizontalPropertyList.fromProperties({
    required List<Property> properties,
  }) {
    return _HorizontalPropertyList(apiProperties: properties);
  }

  @override
  Widget build(BuildContext context) {
    if (apiProperties != null) {
      return SizedBox(
        height: 235,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: apiProperties!.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final p = apiProperties![i];
            final firstImage = p.images.isNotEmpty ? p.images.first : null;
            return _PropertyCard(
              tag: p.transactionType,
              title: p.title,
              price: '₹${p.price}',
              location: '${p.locality}, ${p.city}',
              imageUrl: firstImage,
            );
          },
        ),
      );
    }

    final localList = properties ?? [];

    return SizedBox(
      height: 235,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: localList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final p = localList[i];
          return _PropertyCard(
            tag: p['tag'] ?? '',
            title: p['title'] ?? '',
            price: p['price'] ?? '',
            location: p['location'] ?? '',
          );
        },
      ),
    );
  }
}

// ------------------------
// PROPERTY CARD
// ------------------------
class _PropertyCard extends StatelessWidget {
  final String tag;
  final String title;
  final String price;
  final String location;
  final String? imageUrl;

  const _PropertyCard({
    required this.tag,
    required this.title,
    required this.price,
    required this.location,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/onboarding1.png',
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.favorite_border, size: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF2FED9A),
                      child: Icon(Icons.arrow_forward, size: 16, color: Colors.green.shade800),
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
}

// ------------------------
// SERVICES GRID — fixed height to prevent overflow
// ------------------------
class _ServicesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  const _ServicesGrid({required this.services});

  @override
  Widget build(BuildContext context) {
    // tuned height and aspect ratio to avoid fractional pixel overflow
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Our Service",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ),
        const SizedBox(height: 12),

        // Fixed height grid — prevents RenderFlex micro-overflow
        SizedBox(
          height: 200,
          child: GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, i) {
              final s = services[i];
              return _ServiceItem(
                pngAsset: s['asset'] as String, // ✅ PNG asset
                label: s['label'] as String,
              );
            },
          ),
        ),

      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String pngAsset;
  final String label;

  const _ServiceItem({
    required this.pngAsset,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD0E1FF),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30,
            child: Image.asset(
              pngAsset,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------
// HORIZONTAL PROJECTS LIST
// ------------------------
class _HorizontalProjectsList extends StatelessWidget {
  final List<Map<String, String>> _projects = const [
    {
      'title': 'AJNARA',
      'subtitle': 'PEACE OF MIND',
      'desc': 'Choose from premium villas & apartments.',
    },
    {
      'title': 'PROJECT 2',
      'subtitle': 'LUXURY LIVING',
      'desc': 'Premium properties in prime locations.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _projects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final p = _projects[i];
          return Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [Colors.greenAccent.withOpacity(0.2), Colors.lightBlueAccent.withOpacity(0.2)]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['title']!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text(p['subtitle']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text(p['desc']!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF2FED9A), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Explore Now", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 14, color: Colors.black),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// ------------------------
// BLOG SECTION
// ------------------------
class _BlogSection extends StatelessWidget {
  final List<Map<String, dynamic>> blogs;
  final VoidCallback onViewBlog;

  const _BlogSection({required this.blogs, required this.onViewBlog});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Real Estate Insights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(onTap: onViewBlog, child: const Text("View Blog", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2FED9A)))),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            itemCount: blogs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final b = blogs[i];
              return _BlogCard(title: b['title'] as String, image: b['image'] as String, bg: b['bg'] as Color);
            },
          ),
        )
      ],
    );
  }
}

class _BlogCard extends StatelessWidget {
  final String title;
  final String image;
  final Color bg;

  const _BlogCard({required this.title, required this.image, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, spreadRadius: 1)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Container(height: 80, width: double.infinity, color: bg.withOpacity(0.3), child: Image.asset(image, fit: BoxFit.cover)),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            const Row(children: [
              Text("Read more", style: TextStyle(fontSize: 11, color: Color(0xFF2FED9A), fontWeight: FontWeight.w600)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 12, color: Color(0xFF2FED9A)),
            ])
          ]),
        ),
      ]),
    );
  }
}

// ------------------------
// CTA SELL/RENT CARD
// ------------------------
class _SellingRentingCard extends StatelessWidget {
  final VoidCallback onPost;
  const _SellingRentingCard({required this.onPost});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryColor), ),
      child: Column(children: [
        const Text("Selling or Renting ?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          "Post your property for free and reach thousands of buyers.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPost,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2FED9A), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Post Your Property", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }
}
