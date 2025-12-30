import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hunt_property/screen/filter_screen.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/property_service.dart';
import 'package:hunt_property/models/property_models.dart';
import 'package:intl/intl.dart';

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

  final PropertyService _propertyService = PropertyService();
  List<Property> _allProperties = [];
  List<Property> _searchResults = [];
  bool _isLoadingProperties = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoadingProperties = true;
    });

    try {
      final properties = await _propertyService.getProperties();
      setState(() {
        _allProperties = properties;
        _isLoadingProperties = false;
      });
      print('✅ Loaded ${properties.length} properties from database');
    } catch (e) {
      setState(() {
        _isLoadingProperties = false;
      });
      print('❌ Error loading properties: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading properties: $e')),
        );
      }
    }
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

      // Filter properties based on search query and selected type
      final filtered = _allProperties.where((property) {
        // Match transaction type (BUY = Sell/Buy, RENT = Rent)
        final transactionTypeLower = property.transactionType.toLowerCase();
        final transactionMatch = _selectedType == "BUY"
            ? (transactionTypeLower.contains("sell") || 
               transactionTypeLower.contains("buy"))
            : transactionTypeLower.contains("rent");

        if (!transactionMatch) return false;

        // Search in multiple fields - even if title is empty, search other fields
        final searchableText = [
          property.title,
          property.locality,
          property.city,
          property.address,
          property.buildingName,
          property.propertySubtype,
          property.propertyCategory,
          property.description,
        ]
            .where((text) => text.isNotEmpty)
            .join(" ")
            .toLowerCase();

        // If no searchable text at all, still show the property if query matches transaction type
        if (searchableText.isEmpty) {
          return true; // Show properties even with empty fields
        }

        return searchableText.contains(q);
      }).toList();

      setState(() {
        _isSearching = false;
        _searchResults = filtered;
      });
      
      print('🔍 Search results: ${filtered.length} properties found for "$q"');
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
              onTap: () {
                setState(() => _selectedType = "BUY");
                // Re-perform search when type changes
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
              },
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
              onTap: () {
                setState(() => _selectedType = "RENT");
                // Re-perform search when type changes
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
              },
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
    if (_isLoadingProperties) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2FED9A)),
      );
    }

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
        final property = _searchResults[index];
        return _propertyItem(property);
      },
    );
  }

  // ---------------------------------------------
  // SINGLE PROPERTY CARD
  // ---------------------------------------------
  Widget _propertyItem(Property property) {
    // Determine if it's a rent property
    final isRentProperty = property.transactionType.toLowerCase().contains("rent");
    
    // Format price - prioritize monthlyRent for rent properties, otherwise use price
    String priceText = '';
    if (isRentProperty) {
      // For rent properties, check monthlyRent first
      if (property.monthlyRent.isNotEmpty) {
        final rentValue = num.tryParse(property.monthlyRent);
        if (rentValue != null && rentValue > 0) {
          if (rentValue >= 100000) {
            priceText = '₹ ${(rentValue / 100000).toStringAsFixed(2)} Lacs/month';
          } else {
            priceText = '₹ ${NumberFormat('#,###').format(rentValue)}/month';
          }
        } else {
          priceText = '₹ ${property.monthlyRent}/month';
        }
      } else if (property.price > 0) {
        if (property.price >= 100000) {
          priceText = '₹ ${(property.price / 100000).toStringAsFixed(2)} Lacs/month';
        } else {
          priceText = '₹ ${NumberFormat('#,###').format(property.price)}/month';
        }
      }
    } else {
      // For buy/sell properties, use price
      if (property.price > 0) {
        if (property.price >= 10000000) {
          priceText = '₹ ${(property.price / 10000000).toStringAsFixed(2)} Cr';
        } else if (property.price >= 100000) {
          priceText = '₹ ${(property.price / 100000).toStringAsFixed(2)} Lacs';
        } else {
          priceText = '₹ ${NumberFormat('#,###').format(property.price)}';
        }
      }
    }

    // Format BHK information
    String bhkText = '';
    if (property.bedrooms > 0) {
      bhkText = '${property.bedrooms}BHK';
    }

    // Format location with BHK if available - use fallback if empty
    String locationText = '';
    if (bhkText.isNotEmpty) {
      locationText = bhkText;
    }
    
    if (property.locality.isNotEmpty) {
      if (locationText.isNotEmpty) {
        locationText += ' • ${property.locality}';
      } else {
        locationText = property.locality;
      }
      if (property.city.isNotEmpty) {
        locationText += ', ${property.city}';
      }
    } else if (property.city.isNotEmpty) {
      if (locationText.isNotEmpty) {
        locationText += ' • ${property.city}';
      } else {
        locationText = property.city;
      }
    } else if (property.address.isNotEmpty) {
      if (locationText.isNotEmpty) {
        locationText += ' • ${property.address}';
      } else {
        locationText = property.address;
      }
    }
    
    // Fallback if all location fields are empty
    if (locationText.isEmpty) {
      locationText = 'Location not specified';
    }

    // Format size and type with additional details
    String sizeTypeText = '';
    if (property.areaSqft > 0) {
      sizeTypeText = '${property.areaSqft.toStringAsFixed(0)} Sq Ft';
    }
    
    // Add property subtype
    if (property.propertySubtype.isNotEmpty) {
      if (sizeTypeText.isNotEmpty) {
        sizeTypeText += ' • ${property.propertySubtype}';
      } else {
        sizeTypeText = property.propertySubtype;
      }
    }
    
    // Add furnishing if available
    if (property.furnishing.isNotEmpty && property.furnishing.toLowerCase() != 'none') {
      if (sizeTypeText.isNotEmpty) {
        sizeTypeText += ' • ${property.furnishing}';
      } else {
        sizeTypeText = property.furnishing;
      }
    }
    
    // Add bathrooms if available
    if (property.bathrooms > 0) {
      final bathroomText = '${property.bathrooms} ${property.bathrooms == 1 ? 'Bath' : 'Baths'}';
      if (sizeTypeText.isNotEmpty) {
        sizeTypeText += ' • $bathroomText';
      } else {
        sizeTypeText = bathroomText;
      }
    }
    
    // Fallback if all size/type fields are empty
    if (sizeTypeText.isEmpty) {
      sizeTypeText = property.propertyCategory.isNotEmpty 
          ? property.propertyCategory 
          : 'Property details';
    }

    // Format date
    String dateText = '';
    if (property.postedAt != null) {
      dateText = DateFormat('dd MMMM yyyy').format(property.postedAt!);
    }

    // Get first image or use placeholder
    String imageUrl = property.images.isNotEmpty
        ? property.images.first
        : 'assets/images/onboarding1.png';

    // Generate title - use fallback if empty
    String displayTitle = property.title.isNotEmpty 
        ? property.title 
        : '${property.propertySubtype.isNotEmpty ? property.propertySubtype : property.propertyCategory} ${property.bedrooms > 0 ? "${property.bedrooms}BHK" : ""}'.trim();
    
    if (displayTitle.isEmpty) {
      displayTitle = 'Property Listing';
    }

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
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/onboarding1.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    imageUrl,
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
                  Text(
                    displayTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (locationText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      locationText,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textLight),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (sizeTypeText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      sizeTypeText,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textLight),
                    ),
                  ],
                  if (dateText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textLight),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    priceText.isNotEmpty ? priceText : 'Price on request',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF13E68A),
                        fontWeight: FontWeight.bold),
                  ),
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
