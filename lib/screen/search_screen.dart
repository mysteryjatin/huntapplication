import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/filter_cubit.dart';
import 'package:hunt_property/screen/filter_screen.dart';
import 'package:hunt_property/services/filter_service.dart';
import 'package:hunt_property/services/property_service.dart';
import 'package:hunt_property/models/property_models.dart';
import 'package:hunt_property/models/filter_models.dart';
import 'package:hunt_property/utils/property_search_matcher.dart';
import 'package:intl/intl.dart';
import 'package:hunt_property/screen/property_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const SearchScreen({super.key, this.onBackPressed});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _selectedType = "BUY";
  FilterSelection? _activeFilters;
  bool _isSearching = false;
  bool _isSearchFocused = false;
  bool _isLoadingProperties = false;

  Timer? _searchTimer;

  final PropertyService _propertyService = PropertyService();
  List<Property> _allProperties = [];
  List<Property> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoadingProperties = true);
    final properties = await _propertyService.getProperties();
    setState(() {
      _allProperties = properties;
      _isLoadingProperties = false;
    });
  }

  void _performSearch(String query) {
    _searchTimer?.cancel();

    // Treat any returned FilterSelection (even if only category/transaction type)
    // as an active filter so that tapping "Apply" in the bottom sheet always
    // triggers a search, even when the query is empty.
    final hasRealFilters = (_activeFilters?.hasAnyFilter ?? false);
    final hasFilterObject = _activeFilters != null;
    final hasFilters = hasRealFilters || hasFilterObject;

    if (query.trim().isEmpty && !hasFilters) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      // User ne search text clear kar diya -> keyboard bhi hide kar do
      if (_searchFocusNode.hasFocus) {
        _searchFocusNode.unfocus();
      }
      return;
    }

    setState(() => _isSearching = true);

    _searchTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        // Always base search on the latest text in the field
        final currentText = _searchController.text;
        final qLower = currentText.toLowerCase().trim();

        // If user types "2bhk", "3 bhk" etc., also apply a bedrooms filter
        FilterSelection? effectiveFilters = _activeFilters;
        final bhk = PropertySearchMatcher.parseBhk(qLower);
        if (bhk != null && bhk > 0) {
          if (effectiveFilters == null) {
            effectiveFilters = FilterSelection(
              category: _selectedType,
              bedrooms: bhk,
              bedroomsList: [bhk],
              city: null,
              locality: null,
              propertyCategory: null,
              propertySubtype: null,
              furnishing: null,
              facing: null,
              possessionStatus: null,
              availabilityMonth: null,
              availabilityYear: null,
              ageOfConstruction: null,
              budgetMin: null,
              budgetMax: null,
              areaMin: null,
              areaMax: null,
              bathrooms: null,
              storeRoom: null,
              servantRoom: null,
            );
          } else {
            effectiveFilters = effectiveFilters.copyWith(
              bedrooms: bhk,
              bedroomsList: [bhk],
            );
          }
        }

        var results = await _propertyService.searchProperties(
          query: currentText,
          filters: effectiveFilters,
          type: _selectedType,
          page: 1,
          limit: 50,
        );

        results = PropertySearchMatcher.withFallback(
          results,
          _allProperties,
          currentText,
          _selectedType,
          bhk,
        );

        // If user has already changed the text again, ignore this older response
        final latestText = _searchController.text.toLowerCase().trim();
        if (latestText != qLower) {
          return;
        }

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });

        // As soon as search complete and list updated, keyboard hide kar do
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      } catch (e) {
        // ignore: avoid_print
        print('❌ SEARCH FAILED: $e');
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _searchBar(),
            const SizedBox(height: 8),
            _buyRentToggle(),
            const SizedBox(height: 8),
            Expanded(child: _buildContentArea()),
          ],
        ),
      ),
    );
  }

  // ---------------- CONTENT ----------------

  Widget _buildContentArea() {
    if (_isLoadingProperties || _isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2FED9A)),
      );
    }

    if (_searchResults.isNotEmpty) {
      return _buildSearchResults();
    }

    // Agar search text ya active filters hain, lekin result 0 hai,
    // to "No property found" dikhana hai.
    final hasFilters = _activeFilters?.hasAnyFilter ?? false;
    if (_searchController.text.isNotEmpty || hasFilters) {
      return _buildNotFoundScreen();
    }

    // No query, no filters, no results -> kuch bhi mat dikhao
    return const SizedBox.shrink();
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _propertyItem(_searchResults[index]);
      },
    );
  }

  // ---------------- PROPERTY CARD ----------------

  Widget _propertyItem(Property property) {
    // Prepare display values
    final imageUrl = property.images.isNotEmpty ? property.images.first : null;
    final priceText = (property.price is num && property.price > 0)
        ? '₹ ${NumberFormat('#,###').format(property.price)}'
        : '₹ 0';
    final dateText = property.postedAt != null ? DateFormat('dd MMM yyyy').format(property.postedAt!) : '';
    final location = '${property.locality}${property.city.isNotEmpty ? ', ${property.city}' : ''}';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyDetailsScreen(
              propertyId: property.id,
              // Search results me abhi favorite state directly available nahi,
              // isliye yahan initialIsFavorite false hi rahega.
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF5FAFF), borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl != null ? Image.network(imageUrl, fit: BoxFit.cover) : Image.asset('assets/images/onboarding1.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            // TEXT AREA
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                            // Prefer structured bedrooms field for BHK label to avoid mismatch
                            property.bedrooms > 0
                                ? '${property.bedrooms} BHK'
                                : (property.title.isNotEmpty
                                    ? property.title
                                    : 'Flat in best offer'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      const Icon(Icons.favorite_border, size: 18, color: Colors.black54),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text('360 Sq Ft • Freehold', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: Text(dateText, style: const TextStyle(fontSize: 11, color: Colors.grey))),
                      Text(priceText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- NOT FOUND ----------------

  Widget _buildNotFoundScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/no_proerty_found.png", width: 220),
          const SizedBox(height: 10),
          const Text(
            "No property found",
            style: TextStyle(color: Colors.black, fontSize: 16,),
          ),
        ],
      ),
    );
  }

  // ---------------- UI PARTS ----------------

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _performSearch,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _searchFocusNode.unfocus(); // hide keyboard when user hits search/done
          _performSearch(value);
        },
        decoration: InputDecoration(
          hintText: "Search your area, project",
          prefixIcon: const Icon(Icons.search),

          // FILTER ICON (UI same)
          suffixIcon: GestureDetector(
            onTap: () async {
              final result = await showModalBottomSheet<FilterSelection>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.black.withOpacity(0.4),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    return BlocProvider(
                      create: (_) => FilterCubit(FilterService()),
                      child: FilterScreen(
                        scrollController: scrollController,
                        initialSelection: _activeFilters,
                      ),
                    );
                  },
                ),
              );

              if (result != null) {
                setState(() {
                  _activeFilters = result;
                  _selectedType = result.category;
                });
                _performSearch(_searchController.text);
              }
            },
            child: const Icon(Icons.tune),
          ),

          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buyRentToggle() {
    return Row(
      children: ["BUY", "RENT"].map((type) {
        final selected = _selectedType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedType = type);
              if (_searchController.text.isNotEmpty) {
                _performSearch(_searchController.text);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 44,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2FED9A) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(type,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

