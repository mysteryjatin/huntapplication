// home_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hunt_property/screen/add_post_screen.dart';
import 'package:hunt_property/screen/blog_detail_screen.dart';
import 'package:hunt_property/screen/notification_screen.dart';
import 'package:hunt_property/screen/profile_screen.dart';
import 'package:hunt_property/screen/property_details_screen.dart';
import 'package:hunt_property/screen/search_screen.dart';
import 'package:hunt_property/screen/shortlist_screen.dart';
import 'package:hunt_property/screen/side_menu_screen.dart';
import 'package:hunt_property/screen/spin_popup_screen.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/property_service.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/models/property_models.dart';
import 'package:hunt_property/models/filter_models.dart';
import 'package:hunt_property/utils/property_search_matcher.dart';
import 'filter_screen.dart';
import 'widget/custombottomnavbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/filter_cubit.dart';
import 'package:hunt_property/services/filter_service.dart';
import 'package:hunt_property/services/favorites_sync.dart';
import 'package:hunt_property/services/shortlist_service.dart';
import 'package:hunt_property/cubit/shortlist_cubit.dart';
import 'package:hunt_property/cubit/home_cubit.dart';
import 'package:hunt_property/cubit/home_state.dart';
import 'package:hunt_property/repositories/home_repository.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// Service target screens
import 'package:hunt_property/screen/sidemenu_screen/home_loan_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/property_cost_calculator.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/vastuaiexpert_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/channel_partner_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/legal_advisory_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/nri_center_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/rera_service_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/search_agent_screen.dart';
import 'package:hunt_property/repositories/notification_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int selectedIndex = 0;
  // -1 means "no top tab filter (show all)" when coming from bottom Home
  int _selectedCategoryIndex = -1;
  // BUY/RENT toggle when Projects, Residential, or Commercial tab is selected (0=Buy, 1=Rent)
  int _categoryBuyRentIndex = 0;
  int _carouselPage = 0;
  bool _isSearchFocused = false;

  final PageController _carouselController = PageController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<SideMenuScreenState> _sideMenuKey =
      GlobalKey<SideMenuScreenState>();
  final PropertyService _propertyService = PropertyService();
  Timer? _searchTimer;
  FilterSelection? _activeFilters;
  // All latest properties from API
  List<Property> _allProperties = [];
  // Currently visible properties after filters (Buy/Rent etc.) or search results
  List<Property> _properties = [];
  HomeCubit? _homeCubit;
  final ShortlistService _shortlistService = ShortlistService();
  Set<String> _favoriteIds = {};
  String _selectedCity = '';
  String _selectedState = '';
  bool _isLoadingProperties = false;
  bool _isAutoLocation = true;
  int _autoLocationRequestId = 0; // invalidates in-flight GPS detection when user selects manually
  int _unreadNotificationCount = 0;
  final NotificationRepository _notificationRepository = NotificationRepository();

  // Simple state → cities mapping for location picker (subset of Indian cities)
  final List<String> _states = const [
    'Delhi',
    'Uttar Pradesh',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'Telangana',
    'West Bengal',
  ];

  final Map<String, List<String>> _citiesByState = const {
    'Delhi': ['New Delhi', 'Dwarka', 'Rohini', 'Saket'],
    'Uttar Pradesh': ['Noida', 'Greater Noida', 'Ghaziabad', 'Lucknow', 'Kanpur'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Mangaluru'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai'],
    'Telangana': ['Hyderabad', 'Warangal'],
    'West Bengal': ['Kolkata', 'Howrah'],
  };
  // Top tab labels (without "All"; All is controlled by bottom Home)
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
      'image': 'assets/images/yeid.jpg',
      'bg': const Color(0xFF66BB6A)
    },
  ];

  void _onFavoritesSyncRevision() {
    _loadFavorites();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FavoritesSync.revision.addListener(_onFavoritesSyncRevision);
    _searchFocusNode.addListener(
          () => setState(() => _isSearchFocused = _searchFocusNode.hasFocus),
    );
    _loadProperties();
    _loadSelectedCity();
    _initHomeCubit();
    _loadFavorites(); // ensure favorites loaded when home opens
    _loadUnreadNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFavorites();
    }
  }

  Future<void> _loadUnreadNotifications() async {
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) return;
    final count = await _notificationRepository.getUnreadCount(userId);
    if (!mounted) return;
    setState(() {
      _unreadNotificationCount = count;
    });
  }

  Future<void> _loadSelectedCity() async {
    final c = await StorageService.getSelectedCity();
    if (c != null && c.isNotEmpty) {
      setState(() {
        _selectedCity = c;
        _isAutoLocation = false;
        _autoLocationRequestId++; // invalidate any in-flight auto-detect
      });
      // Saved city exists → do NOT run GPS auto-detect on startup
      return;
    }

    // Har app launch par try karo current location detect karne ka,
    // sirf tab jab user ne manually location override nahi kiya ho.
    if (_isAutoLocation) {
      await _detectUserCity();
    }
  }

  bool _cityMatches(String propertyCity, String selectedCity) {
    final pc = propertyCity.trim().toLowerCase();
    final sc = selectedCity.trim().toLowerCase();
    if (sc.isEmpty) return true;
    if (pc.isEmpty) return false;
    return pc == sc || pc.contains(sc) || sc.contains(pc);
  }

  void _applySelectedLocationToLatestList() {
    final selectedCity = _selectedCity.trim();
    final txn = _selectedCategoryIndex == 1 ? 'rent' : (_selectedCategoryIndex == 0 ? 'sale' : null);

    var list = List<Property>.from(_allProperties);
    if (selectedCity.isNotEmpty) {
      list = list.where((p) => _cityMatches(p.city, selectedCity)).toList();
    }
    if (txn != null) {
      list = list.where((p) => p.transactionType.toLowerCase() == txn).toList();
    }
    setState(() {
      _properties = list;
    });
  }

  Future<void> _onCategorySelected(int idx) async {
    // If "Agents" tab is tapped, open SearchAgentsScreen instead of filtering properties
    if (categories[idx] == 'Agents') {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SearchAgentsScreen(),
        ),
      );
      return;
    }

    setState(() {
      _selectedCategoryIndex = idx; // 0=Buy,1=Rent, others = sections only
      if (idx >= 2 && idx <= 4) _categoryBuyRentIndex = 0; // Reset BUY/RENT when switching to Projects/Residential/Commercial
    });

    String? txn;
    String? category;
    final label = categories[idx].toLowerCase();
    if (label == 'buy') txn = 'sale';
    if (label == 'rent') txn = 'rent';
    if (label == 'projects') category = 'Projects';
    if (label == 'residential') category = 'Residential';
    if (label == 'commercial') category = 'Commercial';

    final userId = await StorageService.getUserId();
    _homeCubit?.fetchHomeWithFilters(
      city: _selectedCity,
      userId: userId,
      limit: 10,
      transactionType: txn,
      propertyCategory: category,
    );

    // For Latest list: apply city + txn filter. If user is actively searching, re-run search.
    final hasSearchOrFilter = _searchController.text.trim().isNotEmpty ||
        (_activeFilters?.hasAnyFilter ?? false);
    if (hasSearchOrFilter && (idx == 0 || idx == 1)) {
      _performSearch(_searchController.text);
    } else {
      _applySelectedLocationToLatestList();
    }
  }

  /// Detect user's current city from GPS once, and use it as the default city
  /// for home screen. If permission denied or lookup fails, keep existing city.
  Future<void> _detectUserCity() async {
    final int requestId = ++_autoLocationRequestId;
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        // Silent fallback: user ne permission deny ki, to default city hi rahegi.
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isEmpty) return;

      final p = placemarks.first;
      // Prefer locality/city fields from placemark
      final detectedCity =
          (p.locality?.trim().isNotEmpty == true ? p.locality : null) ??
              (p.subAdministrativeArea?.trim().isNotEmpty == true
                  ? p.subAdministrativeArea
                  : null) ??
              (p.administrativeArea?.trim().isNotEmpty == true
                  ? p.administrativeArea
                  : null);

      final detectedState =
          (p.administrativeArea?.trim().isNotEmpty == true
              ? p.administrativeArea
              : null) ??
          (p.subAdministrativeArea?.trim().isNotEmpty == true
              ? p.subAdministrativeArea
              : null);

      if (detectedCity == null || detectedCity.trim().isEmpty) return;

      final cityName = detectedCity.trim();
      final stateName = detectedState?.trim() ?? '';

      // If user has manually selected a city while GPS was in-flight, ignore GPS result.
      if (!mounted || !_isAutoLocation || requestId != _autoLocationRequestId) return;
      setState(() {
        _selectedCity = cityName;
        _selectedState = stateName;
        _isAutoLocation = true;
      });
      await StorageService.saveSelectedCity(cityName);

      // Apply selected city to latest list immediately (no search query)
      if (_searchController.text.trim().isEmpty && (_activeFilters?.hasAnyFilter != true)) {
        _applySelectedLocationToLatestList();
      }

      // Refresh home sections for this detected city
      final userId = await StorageService.getUserId();
      _homeCubit?.fetchHome(city: cityName, userId: userId, limit: 10);
    } catch (e) {
      // ignore: avoid_print
      print('❌ DETECT USER CITY FAILED: $e');
    }
  }

  void _initHomeCubit() async {
    _homeCubit = HomeCubit(HomeRepository(service: _propertyService));
    final userId = await StorageService.getUserId();
    _homeCubit?.fetchHome(city: _selectedCity, userId: userId, limit: 10);
  }

  Future<void> _loadFavorites() async {
    try {
      final ids = await _shortlistService.getAllShortlistedPropertyIds();
      if (!mounted) return;
      setState(() {
        _favoriteIds = ids;
      });
    } catch (e) {
      // ignore: avoid_print
      print('❌ LOAD FAVORITES ERROR: $e');
    }
  }

  Future<void> _selectCityDialog() async {
    String? tempState = _selectedState.isNotEmpty ? _selectedState : null;
    String? tempCity = _selectedCity.isNotEmpty ? _selectedCity : null;

    // If the current state (from GPS / backend) is not in our predefined list,
    // clear it so DropdownButtonFormField doesn't throw (value must be in items).
    if (tempState != null && tempState!.trim().isNotEmpty) {
      final normalized = tempState!.trim().toLowerCase();
      final match = _states.where((s) => s.toLowerCase() == normalized).toList();
      tempState = match.isNotEmpty ? match.first : null;
    }

    final res = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final stateItems = List<String>.from(_states)..sort();

          // Re-validate state inside dialog (because stateItems is the actual source).
          if (tempState != null &&
              !stateItems.any((s) => s.toLowerCase() == tempState!.toLowerCase())) {
            tempState = null;
          }

          final cityItems = tempState != null
              ? (() {
                  final list = List<String>.from(_citiesByState[tempState] ?? []);
                  if (tempCity != null &&
                      tempCity!.isNotEmpty &&
                      !list.any((c) => c.toLowerCase() == tempCity!.toLowerCase())) {
                    list.insert(0, tempCity!);
                  }
                  list.sort();
                  return list;
                })()
              : <String>[];

          return AlertDialog(
            title: const Text('Select City'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'State',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: tempState,
                  decoration: const InputDecoration(
                    hintText: 'Select State',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: stateItems
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[900],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setStateDialog(() {
                      tempState = v;
                      tempCity = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'City',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: tempCity,
                  decoration: const InputDecoration(
                    hintText: 'Select City',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: cityItems
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[900],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setStateDialog(() => tempCity = v);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (tempCity == null || tempCity!.isEmpty) {
                    Navigator.pop(context);
                    return;
                  }
                  Navigator.pop(context, {
                    'city': tempCity!,
                    'state': tempState ?? '',
                  });
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (res != null && (res['city']?.isNotEmpty ?? false)) {
      final newCity = res['city']!.trim();
      final newState = (res['state'] ?? '').trim();

      await StorageService.saveSelectedCity(newCity);
      setState(() {
        _selectedCity = newCity;
        _selectedState = newState;
        _isAutoLocation = false;
        _autoLocationRequestId++; // stop/ignore any in-flight GPS auto-detect
      });

      // Update latest list immediately for selected city
      if (_searchController.text.trim().isEmpty && (_activeFilters?.hasAnyFilter != true)) {
        _applySelectedLocationToLatestList();
      } else {
        _performSearch(_searchController.text);
      }
      // refetch home with new city
      final userId = await StorageService.getUserId();
      _homeCubit?.fetchHomeWithFilters(city: _selectedCity, userId: userId, limit: 10);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FavoritesSync.revision.removeListener(_onFavoritesSyncRevision);
    _searchTimer?.cancel();
    _carouselController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _homeCubit?.close();
    super.dispose();
  }

  // Handle Add button click with spin popup check
  Future<void> _handleAddButtonClick() async {
    print('🔘 Add button clicked from bottom navigation');
    
    // Check if user has added any properties
    final userPropertiesCount = await _propertyService.getUserPropertiesCount();
    print('📊 User properties count: $userPropertiesCount');
    
    // Show spin popup ONLY if user has exactly 0 properties
    // If count is 1 or greater, no popup will appear - go directly to add post screen
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
      // User has 1 or more properties - no popup, go directly to add post
      print('⚠️ User has $userPropertiesCount properties (count > 0), skipping popup and going directly to add post');
    }
    
    // If user has properties (count >= 1), go directly to add post without popup
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
    // Back handling: only allow the route to actually pop (exit app) when we are on
    // the home tab AND the navigator has a single route (nothing under `/home`).
    // Otherwise we intercept: switch to home tab, or normalize stack to `/home` only
    // (e.g. login left under the stack). WillPopScope alone could still allow exit
    // in some nested flows; PopScope + canPop matches that intent.
    final nav = Navigator.of(context);
    final bool allowExit = selectedIndex == 0 && !nav.canPop();
    return PopScope(
      canPop: allowExit,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (selectedIndex != 0) {
          setState(() => selectedIndex = 0);
          return;
        }
        if (nav.canPop()) {
          nav.pushNamedAndRemoveUntil('/home', (route) => false);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        onDrawerChanged: (isOpened) {
          if (isOpened) {
            _sideMenuKey.currentState?.refreshMembershipFromStorage();
          }
        },
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
              setState(() {
                selectedIndex = i;
              if (i == 0) {
                // Bottom Home tab: show ALL properties, clear search/filter
                _selectedCategoryIndex = -1;
                _activeFilters = null;
                _searchController.clear();
                _properties = List<Property>.from(_allProperties);
              }
              });
              // When returning to Home tab, refresh favorites so heart states update.
              if (i == 0) {
                _loadFavorites();
                // Reset home sections to unfiltered "All" when coming back via bottom Home.
                final userId = await StorageService.getUserId();
                _homeCubit?.fetchHome(city: _selectedCity, userId: userId, limit: 10);
              }
            }
          },
        ),
      ),
    );
  }

  // DRAWER
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.grey[850],
      width: MediaQuery.of(context).size.width * 0.90,
      child: SideMenuScreen(
        key: _sideMenuKey,
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
          onSearchChanged: _performSearch,
          categories: categories,
          selectedCategoryIndex: _selectedCategoryIndex,
          onCategorySelected: (i) => _onCategorySelected(i),
          selectedCity: _selectedCity,
          selectedState: _selectedState,
          showCurrentLocationLabel: _isAutoLocation,
          onLocationTap: _selectCityDialog,
          unreadNotificationCount: _unreadNotificationCount,
          onNotificationTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
            await _loadUnreadNotifications();
          },
        ),

        /// ALL CONTENT — category list view for Projects/Residential/Commercial
        Expanded(
          child: SafeArea(
            top: false,
            child: _selectedCategoryIndex >= 2 && _selectedCategoryIndex <= 4
                ? _CategoryListContent(
                    buyRentIndex: _categoryBuyRentIndex,
                    onBuyRentChanged: (i) => setState(() => _categoryBuyRentIndex = i),
                    properties: _categoryFilteredProperties,
                    favoriteIds: _favoriteIds,
                    isLoading: _isLoadingProperties,
                  )
                : SingleChildScrollView(
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

                  // Latest Properties (from API) - show which type is active (Buy/Rent/All)
                  _sectionTitle(
                    _selectedCategoryIndex == 1
                        ? "Latest Rent Properties"
                        : _selectedCategoryIndex == 0
                            ? "Latest Buy Properties"
                            : "Latest Properties",
                  ),
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
                    _HorizontalPropertyList.fromProperties(properties: _properties, favoriteIds: _favoriteIds),

                  const SizedBox(height: 14),

                  // Show sections depending on selected tab (driven by HomeCubit)
                  if (_selectedCategoryIndex == -1 ||
                      _selectedCategoryIndex == 0 ||
                      _selectedCategoryIndex == 1) ...[
                    BlocBuilder<HomeCubit, HomeState>(
                      bloc: _homeCubit,
                      builder: (context, state) {
                        if (state is HomeLoaded) {
                          final title = state.data.topSellingProjects.sectionTitle.isNotEmpty
                              ? state.data.topSellingProjects.sectionTitle
                              : "Top Selling Projects in Chennai";
                          final props = state.data.topSellingProjects.properties;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle(title),
                              props.isNotEmpty
                                  ? _HorizontalPropertyList.fromProperties(properties: props, favoriteIds: _favoriteIds)
                                  : _HorizontalPropertyList(properties: _topSelling, favoriteIds: _favoriteIds),
                              const SizedBox(height: 14),
                            ],
                          );
                        } else if (state is HomeLoading) {
                          return Column(children: const [
                            SizedBox(height: 8),
                            Center(child: CircularProgressIndicator()),
                            SizedBox(height: 14),
                          ]);
                        }
                        // fallback to sample data
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Top Selling Projects in Chennai"),
                            _HorizontalPropertyList(properties: _topSelling, favoriteIds: _favoriteIds),
                            const SizedBox(height: 14),
                          ],
                        );
                      },
                    ),
                  ],

                  if (_selectedCategoryIndex == -1 ||
                      _selectedCategoryIndex == 0) ...[
                    BlocBuilder<HomeCubit, HomeState>(
                      bloc: _homeCubit,
                      builder: (context, state) {
                        if (state is HomeLoaded) {
                          final recTitle = state.data.recommendYourLocation.sectionTitle.isNotEmpty
                              ? state.data.recommendYourLocation.sectionTitle
                              : "Recommend Your Location";
                          final rentTitle = state.data.propertyForRent.sectionTitle.isNotEmpty
                              ? state.data.propertyForRent.sectionTitle
                              : "Property for Rent";
                          final recProps = state.data.recommendYourLocation.properties;
                          final rentProps = state.data.propertyForRent.properties;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle(recTitle),
                              recProps.isNotEmpty
                                  ? _HorizontalPropertyList.fromProperties(properties: recProps, favoriteIds: _favoriteIds)
                                  : _HorizontalPropertyList(properties: _recommended, favoriteIds: _favoriteIds),
                              const SizedBox(height: 14),
                              _sectionTitle(rentTitle),
                              rentProps.isNotEmpty
                                  ? _HorizontalPropertyList.fromProperties(properties: rentProps, favoriteIds: _favoriteIds)
                                  : _HorizontalPropertyList(properties: _rents, favoriteIds: _favoriteIds),
                              const SizedBox(height: 14),
                            ],
                          );
                        } else if (state is HomeLoading) {
                          return Column(children: const [
                            SizedBox(height: 8),
                            Center(child: CircularProgressIndicator()),
                            SizedBox(height: 14),
                          ]);
                        }
                        // fallback
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Recommend Your Location"),
                            _HorizontalPropertyList(properties: _recommended, favoriteIds: _favoriteIds),
                            const SizedBox(height: 14),
                            _sectionTitle("Property for Rent"),
                            _HorizontalPropertyList(properties: _rents, favoriteIds: _favoriteIds),
                            const SizedBox(height: 14),
                          ],
                        );
                      },
                    ),
                  ],

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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black,),
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

  void _openFilter() async {
    final result = await showModalBottomSheet<FilterSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.4),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => BlocProvider(
          create: (_) => FilterCubit(FilterService()),
          child: FilterScreen(
            scrollController: scrollController,
            initialSelection: _activeFilters,
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _activeFilters = result;
        if (result.category == 'RENT') {
          _selectedCategoryIndex = 1;
        } else {
          _selectedCategoryIndex = 0;
        }
      });
      _performSearch(_searchController.text);
    }
  }

  void _performSearch(String query) {
    _searchTimer?.cancel();

    final hasRealFilters = (_activeFilters?.hasAnyFilter ?? false);
    final hasFilterObject = _activeFilters != null;
    final hasFilters = hasRealFilters || hasFilterObject;

    if (query.trim().isEmpty && !hasFilters) {
      setState(() {
        _properties = List<Property>.from(_allProperties);
        if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 1) {
          final txn = _selectedCategoryIndex == 1 ? 'rent' : 'sale';
          _properties = _allProperties
              .where((p) => p.transactionType.toLowerCase() == txn)
              .toList();
        }
      });
      // Home search me text clear hote hi keyboard bhi hide kar do
      if (_searchFocusNode.hasFocus) {
        _searchFocusNode.unfocus();
      }
      return;
    }

    setState(() => _isLoadingProperties = true);

    _searchTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final type = _selectedCategoryIndex == 1 ? 'RENT' : 'BUY';

        // Hamesha latest text field ka value lo
        final currentText =
            _searchController.text.isNotEmpty ? _searchController.text : query;
        final qLower = currentText.toLowerCase().trim();

        // Agar user "2bhk", "3 bhk" likhe to bedrooms filter bhi apply karo
        FilterSelection? effectiveFilters = _activeFilters;
        final bhk = PropertySearchMatcher.parseBhk(qLower);
        if (bhk != null && bhk > 0) {
          if (effectiveFilters == null) {
            effectiveFilters = FilterSelection(
              category: type,
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
          type: type,
          page: 1,
          limit: 50,
        );

        // BHK + city/locality/amenities (gym, pool, etc.) — refine API results; fallback to full local list
        results = PropertySearchMatcher.withFallback(
          results,
          _allProperties,
          currentText,
          type,
          bhk,
        );

        if (!mounted) return;
        setState(() {
          _properties = results;
          _isLoadingProperties = false;
        });

        // Search complete hone ke baad keyboard hide kar do
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _properties = [];
          _isLoadingProperties = false;
        });
      }
    });
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoadingProperties = true;
    });

    try {
      final props = await _propertyService.getProperties();
      if (!mounted) return;
      setState(() {
        _allProperties = props;
        // Initial view: show properties by selected city (and buy/rent if selected)
        _properties = List<Property>.from(_allProperties);
        _isLoadingProperties = false;
      });
      // Apply location filter once data is loaded
      if (mounted && _searchController.text.trim().isEmpty && (_activeFilters?.hasAnyFilter != true)) {
        _applySelectedLocationToLatestList();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingProperties = false;
      });
    }
  }

  /// Properties filtered by Projects/Residential/Commercial category and BUY/RENT
  List<Property> get _categoryFilteredProperties {
    if (_selectedCategoryIndex < 2 || _selectedCategoryIndex > 4) return [];
    final txn = _categoryBuyRentIndex == 0 ? 'sale' : 'rent';
    final catLabel = categories[_selectedCategoryIndex].toLowerCase();
    return _allProperties.where((p) {
      final matchTxn = p.transactionType.toLowerCase() == txn;
      final matchCity = _selectedCity.trim().isEmpty ? true : _cityMatches(p.city, _selectedCity);
      if (catLabel == 'projects') return matchTxn; // Projects: show all matching txn
      if (catLabel == 'residential') return matchTxn && matchCity && p.propertyCategory.toLowerCase().contains('residential');
      if (catLabel == 'commercial') return matchTxn && matchCity && p.propertyCategory.toLowerCase().contains('commercial');
      return matchTxn && matchCity;
    }).toList();
  }
}

/// Returns icon for amenity label (bed, bathroom, kitchen, etc.)
IconData _getAmenityIcon(String label) {
  final lower = label.toLowerCase();
  if (lower.contains('bedroom')) return Icons.bed_outlined;
  if (lower.contains('bathroom')) return Icons.bathtub_outlined;
  if (lower.contains('kitchen')) return Icons.kitchen_outlined;
  if (lower.contains('lounge') || lower.contains('sofa') || lower.contains('living')) return Icons.weekend_outlined;
  if (lower.contains('balcony') || lower.contains('terrace')) return Icons.deck_outlined;
  if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center_outlined;
  if (lower.contains('parking') || lower.contains('car')) return Icons.local_parking_outlined;
  if (lower.contains('lift') || lower.contains('elevator')) return Icons.elevator_outlined;
  if (lower.contains('pool') || lower.contains('swimming')) return Icons.pool_outlined;
  if (lower.contains('garden') || lower.contains('lawn')) return Icons.grass_outlined;
  if (lower.contains('furnish') || lower.contains('semi') || lower.contains('fully')) return Icons.chair_outlined;
  return Icons.check_circle_outline;
}

// Common price formatter used in home cards
String _formatPropertyPriceHome(Property p) {
  final price = p.price;
  final isRent = p.transactionType.toLowerCase() == 'rent';
  final formatter = NumberFormat.decimalPattern('en_IN');

  if (isRent) {
    // Try numeric monthlyRent first if backend price is 0
    num effective = price;
    if (effective <= 0 && p.monthlyRent.isNotEmpty) {
      final cleaned =
          p.monthlyRent.replaceAll(RegExp(r'[^0-9.]'), '');
      effective = num.tryParse(cleaned) ?? 0;
    }
    if (effective <= 0) return '₹ 0/month';
    return '₹ ${formatter.format(effective)}/month';
  }

  // Sale price
  if (price <= 0) return '₹ 0';

  if (price >= 10000000) {
    final cr = price / 10000000;
    final crStr =
        cr % 1 == 0 ? cr.toStringAsFixed(0) : cr.toStringAsFixed(1);
    return '₹ $crStr Cr';
  } else if (price >= 100000) {
    final lac = price / 100000;
    final lacStr =
        lac % 1 == 0 ? lac.toStringAsFixed(0) : lac.toStringAsFixed(1);
    return '₹ $lacStr Lac';
  }

  return '₹ ${formatter.format(price)}';
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
  final void Function(String)? onSearchChanged;
  final List<String> categories;
  final int selectedCategoryIndex;
  final Function(int) onCategorySelected;
  final String selectedCity;
  final String selectedState;
  final bool showCurrentLocationLabel;
  final VoidCallback onLocationTap;
  final int unreadNotificationCount;
  final Future<void> Function()? onNotificationTap;

  const _HeaderArea({
    required this.scaffoldKey,
    required this.isSearchFocused,
    required this.searchController,
    required this.searchFocusNode,
    required this.onTuneTap,
    this.onSearchChanged,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onCategorySelected,
    required this.selectedCity,
    required this.selectedState,
    required this.showCurrentLocationLabel,
    required this.onLocationTap,
    required this.unreadNotificationCount,
    this.onNotificationTap,
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
                    height: 72,
                    child: Image.asset('assets/images/hunt_property_logo_-removebg-preview.png', fit: BoxFit.fill),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      if (onNotificationTap != null) {
                        await onNotificationTap!();
                      } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      }
                    },
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          size: 26,
                          color: Colors.black,
                        ),
                        if (unreadNotificationCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadNotificationCount > 99
                                    ? '99+'
                                    : unreadNotificationCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )

                ],
              ),
            ),

            // Selected location row (logo ke niche)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onLocationTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showCurrentLocationLabel) ...[
                        const Text(
                          'Current location',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            selectedState.isNotEmpty
                                ? '$selectedCity, $selectedState'
                                : selectedCity,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
                        onChanged: onSearchChanged,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          // Keyboard hide + explicit search trigger
                          searchFocusNode.unfocus();
                          if (onSearchChanged != null) {
                            onSearchChanged!(value);
                          }
                        },
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


            // Categories (scrollable tabs)
            SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 18),
                itemBuilder: (context, idx) {
                  final label = categories[idx];
                  final selected = idx == selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () => onCategorySelected(idx),
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
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: selected ? 32 : 0,
                          decoration: BoxDecoration(
                            color: selected ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
// CATEGORY LIST CONTENT — same design as image for Projects/Residential/Commercial
// ------------------------
class _CategoryListContent extends StatelessWidget {
  final int buyRentIndex;
  final Function(int) onBuyRentChanged;
  final List<Property> properties;
  final Set<String> favoriteIds;
  final bool isLoading;

  const _CategoryListContent({
    required this.buyRentIndex,
    required this.onBuyRentChanged,
    required this.properties,
    required this.favoriteIds,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // BUY/RENT toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: ['BUY', 'RENT'].asMap().entries.map((e) {
              final selected = buyRentIndex == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onBuyRentChanged(e.key),
                  child: Container(
                    margin: EdgeInsets.only(left: e.key == 1 ? 8 : 0, right: e.key == 0 ? 8 : 0),
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF2FED9A) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: selected ? Colors.black : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Property list
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2FED9A)))
              : properties.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No properties found. Try adding one from "Post Your Property".',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: properties.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _VerticalPropertyCard(
                            property: properties[i],
                            isFavorite: favoriteIds.contains(properties[i].id),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ------------------------
// VERTICAL PROPERTY CARD — full-width design matching image
// ------------------------
class _VerticalPropertyCard extends StatefulWidget {
  final Property property;
  final bool isFavorite;

  const _VerticalPropertyCard({required this.property, required this.isFavorite});

  @override
  State<_VerticalPropertyCard> createState() => _VerticalPropertyCardState();
}

class _VerticalPropertyCardState extends State<_VerticalPropertyCard> {
  late bool _isFavorite;
  final ShortlistService _shortlistService = ShortlistService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant _VerticalPropertyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) _isFavorite = widget.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to save favorites')));
      }
      return;
    }
    setState(() => _isFavorite = !_isFavorite);
    final success = _isFavorite
        ? await _shortlistService.addToShortlist(widget.property.id)
        : await _shortlistService.removeFromShortlist(widget.property.id);
    if (!success) {
      setState(() => _isFavorite = !_isFavorite);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update favorites')));
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites')));
    }
    FavoritesSync.notifyChanged();
    try {
      BlocProvider.of<ShortlistCubit>(context, listen: false).load();
    } catch (_) {}
    try {
      final homeState = context.findAncestorStateOfType<_HomeScreenState>();
      await homeState?._loadFavorites();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final imageUrl = p.images.isNotEmpty ? p.images.first : null;
    final priceStr = _formatPropertyPriceHome(p);
    final location = '${p.locality}${p.city.isNotEmpty ? ', ${p.city}' : ''}';
    final dateStr = p.postedAt != null ? DateFormat('dd MMMM yyyy').format(p.postedAt!) : '';

    // Build amenity pills
    final List<String> amenityPills = [];
    if (p.bedrooms > 0) amenityPills.add('${p.bedrooms} Bedrooms');
    if (p.bathrooms > 0) amenityPills.add('${p.bathrooms} Bathroom${p.bathrooms > 1 ? 's' : ''}');
    if (p.furnishing.isNotEmpty) amenityPills.add(p.furnishing);
    if (p.balconies > 0) amenityPills.add('Balcony');
    if (p.amenities.isNotEmpty) {
      for (final a in p.amenities.take(3)) {
        if (a.isNotEmpty && !amenityPills.any((x) => x.toLowerCase().contains(a.toLowerCase()))) {
          amenityPills.add(a);
        }
      }
    }
    if (amenityPills.isEmpty) amenityPills.addAll(['Open Kitchen', 'Lounge Area', 'Balcony', 'Gym Access']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsScreen(
              propertyId: p.id,
              initialIsFavorite: _isFavorite,
            ),
          ),
        ).then((_) {
          context.findAncestorStateOfType<_HomeScreenState>()?._loadFavorites();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : Image.asset('assets/images/onboarding1.png', fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: _isFavorite
                            ? const Icon(Icons.favorite, size: 22, color: AppColors.primaryColor)
                            : const Icon(Icons.favorite_border, size: 22, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.title.isNotEmpty ? p.title : 'Flat in best offer',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, size: 22, color: _isFavorite ? AppColors.primaryColor : Colors.grey.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(location, style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Text('Freehold', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (p.areaSqft > 0) ...[
                        Text(' • ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Text('${p.areaSqft.toInt()} Sq Ft', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: amenityPills.take(6).map((label) {
                      final icon = _getAmenityIcon(label);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(priceStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      if (dateStr.isNotEmpty) Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.black,)),
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
  final Set<String>? favoriteIds;

  const _HorizontalPropertyList({
    this.properties,
    this.apiProperties,
    this.favoriteIds,
  });

  factory _HorizontalPropertyList.fromProperties({
    required List<Property> properties,
    Set<String>? favoriteIds,
  }) {
    return _HorizontalPropertyList(apiProperties: properties, favoriteIds: favoriteIds);
  }

  @override
  Widget build(BuildContext context) {
    // Determine favorites from either passed-in favoriteIds or ShortlistCubit (if available).
    final Set<String> favIds = {};
    if (favoriteIds != null) {
      favIds.addAll(favoriteIds!);
    } else {
      try {
        final s = BlocProvider.of<ShortlistCubit>(context).state;
        if (s is ShortlistLoaded) {
          favIds.addAll(s.properties.map((e) => e.id));
        }
      } catch (_) {
        // ignore
      }
    }

    // Use a 2-column grid to match the screenshot design
    final items = apiProperties != null
        ? apiProperties!
            .map((p) {
              final firstImage = p.images.isNotEmpty ? p.images.first : null;
              final priceStr = _formatPropertyPriceHome(p);

              final isFav = favIds.contains(p.id);

              return {
                'id': p.id,
                'tag': p.transactionType,
                'title': p.title,
                'price': priceStr,
                'location': '${p.locality}, ${p.city}',
                'image': firstImage,
                'is_favorite': isFav,
              };
            })
            .toList()
        : (properties ?? []);

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
            return SizedBox(
              width: 180,
              child: _PropertyCard(
                propertyId: item['id'] as String?,
                tag: item['tag']?.toString() ?? '',
                title: item['title']?.toString() ?? '',
                price: item['price']?.toString() ?? '',
                location: item['location']?.toString() ?? '',
                imageUrl: item['image'] as String?,
                isFavorite: item['is_favorite'] as bool? ?? false,
              ),
            );
        },
      ),
    );
  }
}

// ------------------------
// PROPERTY CARD
// ------------------------
class _PropertyCard extends StatefulWidget {
  final String tag;
  final String title;
  final String price;
  final String location;
  final String? imageUrl;
  final String? propertyId;
  final bool isFavorite;

  const _PropertyCard({
    this.propertyId,
    required this.tag,
    required this.title,
    required this.price,
    required this.location,
    this.imageUrl,
    this.isFavorite = false,
  });

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  late bool _isFavorite;
  final ShortlistService _shortlistService = ShortlistService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant _PropertyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Agar parent ne isFavorite state update ki ho (favoriteIds badalne ke baad),
    // to local _isFavorite ko bhi sync kar do.
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  Future<void> _toggleFavorite() async {
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to save favorites')));
      }
      return;
    }

    final propId = widget.propertyId ?? '';
    if (propId.isEmpty) return;

    setState(() => _isFavorite = !_isFavorite); // optimistic

    bool success = false;
    if (_isFavorite) {
      success = await _shortlistService.addToShortlist(propId);
    } else {
      success = await _shortlistService.removeFromShortlist(propId);
    }

    if (!success) {
      // revert
      setState(() => _isFavorite = !_isFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update favorites')));
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites')));
    }

    FavoritesSync.notifyChanged();
    try {
      final cubit = BlocProvider.of<ShortlistCubit>(context, listen: false);
      cubit.load();
    } catch (_) {}
    try {
      final homeState = context.findAncestorStateOfType<_HomeScreenState>();
      await homeState?._loadFavorites();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final id = widget.propertyId ?? '';
        if (id.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property details not available')),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsScreen(
              propertyId: id,
              initialIsFavorite: _isFavorite,
            ),
          ),
        ).then((_) {
          context.findAncestorStateOfType<_HomeScreenState>()?._loadFavorites();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                        ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                        : Image.asset('assets/images/onboarding1.png', fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: _isFavorite
                            ? const Icon(Icons.favorite, size: 26, color: AppColors.primaryColor)
                            : const Icon(Icons.favorite_border, size: 26, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(widget.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  // Price full width on first line, green arrow slightly below
                  Text(
                    widget.price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2FED9A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              final label = s['label'] as String;
              final png = s['asset'] as String;

              VoidCallback? onTap;
              final key = label.toLowerCase().replaceAll(RegExp(r'\\s+'), ' ');
              if (key.contains('home loan')) {
                onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeLoanScreen()));
              } else if (key.contains('property') && key.contains('worth')) {
                onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertyCostCalculatorScreen()));
              } else if (key.contains('vastu')) {
                onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VastuAiExpertScreen()));
              } else if (key.contains('sell') || key.contains('rent')) {
                onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPostScreen()));
              } else if (key.contains('channel')) {
                onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChannelPartnerScreen()));
              } else if (key.contains('legal')) {
                onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalAdvisoryScreen()));
              } else if (key.contains('nri')) {
                onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NRICenterScreen()));
              } else if (key.contains('rera')) {
                onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReraServicesScreen()));
              }

              return _ServiceItem(
                pngAsset: png,
                label: label,
                onTap: onTap,
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
  final VoidCallback? onTap;

  const _ServiceItem({
    required this.pngAsset,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
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

    if (onTap != null) {
      return InkWell(onTap: onTap, child: card);
    }
    return card;
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
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlogDetailScreen(title: title, image: image, bgColor: bg),
                  ),
                );
              },
              child: Row(
                children: const [
                  Text("Read more", style: TextStyle(fontSize: 11, color: Color(0xFF2FED9A), fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: Color(0xFF2FED9A)),
                ],
              ),
            )
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
        const Text("Selling or Renting ?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black,)),
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
