import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hunt_property/screen/filter_screen.dart';
import 'package:hunt_property/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const SearchScreen({super.key, this.onBackPressed});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedType = "BUY"; // BUY / RENT
  bool _isSearching = false;
  bool _isSearchFocused = false;
  Timer? _searchTimer;

  List<Map<String, dynamic>> _searchResults = [];

  /// Demo list for Delhi
  final List<Map<String, dynamic>> _delhiProperties = [
    {
      "title": "Flat In best offer for Navratra",
      "location": "Uttam Nagar",
      "size": "360 Sq Ft",
      "type": "Freehold",
      "date": "23 October 2019",
      "price": "₹ 19 Lacs",
      "isNew": true,
      "image": "assets/images/onboarding1.png",
    },
    {
      "title": "Flat In best offer for Navratra",
      "location": "Uttam Nagar",
      "size": "360 Sq Ft",
      "type": "Freehold",
      "date": "23 October 2019",
      "price": "₹ 19 Lacs",
      "isNew": false,
      "image": "assets/images/onboarding2.png",
    }
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _performSearch(String query) {
    _searchTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      final q = query.toLowerCase().trim();

      setState(() {
        _isSearching = false;
        _searchResults = q.contains("delhi") ? _delhiProperties : [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _searchBar(),
          _buyRentToggle(),
          Expanded(child: _buildContentArea()),
        ],
      ),
    );
  }

  // ---------------------------------------------
  // SEARCH BAR (Exact screenshot design)
  // ---------------------------------------------
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Back Arrow
          GestureDetector(
            onTap: widget.onBackPressed,
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black, size: 20),
          ),

          const SizedBox(width: 12),

          // Search Field
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: _isSearchFocused
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  // Search Icon
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 10),

                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      cursorColor: AppColors.primaryColor,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: "Search your area, project",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _performSearch,
                    ),
                  ),

                  // Filter Icon
                  GestureDetector(
                    onTap: () {
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
                    },
                    child: const Icon(
                      Icons.tune,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }

  // ---------------------------------------------
  // BUY / RENT Buttons (Pill shape)
  // ---------------------------------------------
  Widget _buyRentToggle() {
    const Color green = Color(0xFF2FED9A);
    const Color greyBorder = Color(0xFFD1D1D1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // BUY BUTTON
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = "BUY"),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 46,
                decoration: BoxDecoration(
                  color: _selectedType == "BUY" ? green : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: _selectedType == "BUY" ? Colors.transparent : greyBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    "BUY",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // RENT BUTTON
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = "RENT"),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 46,
                decoration: BoxDecoration(
                  color: _selectedType == "RENT" ? green : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: _selectedType == "RENT" ? Colors.transparent : greyBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    "RENT",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ---------------------------------------------
  // CONTENT AREA
  // ---------------------------------------------
  Widget _buildContentArea() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2FED9A)),
      );
    }

    if (_searchResults.isNotEmpty) {
      return _buildSearchResults();
    }

    return _buildNotFoundScreen();
  }

  // ---------------------------------------------
  // SEARCH RESULTS LIST
  // ---------------------------------------------
  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final p = _searchResults[index];
        return _propertyItem(p);
      },
    );
  }

  // ---------------------------------------------
  // SINGLE PROPERTY CARD
  // ---------------------------------------------
  Widget _propertyItem(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.asset(
              p["image"],
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),

          // DETAILS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p["title"],
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(p["location"],
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 4),
                  Text("${p["size"]} ${p["type"]}",
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 4),
                  Text(p["date"],
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 8),
                  Text(p["price"],
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF13E68A),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------
  // NOT FOUND
  // ---------------------------------------------
  Widget _buildNotFoundScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/not found.png", width: 240),
        ],
      ),
    );
  }
}
