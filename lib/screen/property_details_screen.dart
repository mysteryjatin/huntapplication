import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/filter_cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hunt_property/cubit/property_cubit.dart';
import 'package:hunt_property/cubit/shortlist_cubit.dart';
import 'package:hunt_property/models/filter_models.dart';
import 'package:hunt_property/models/property.dart';
import 'package:hunt_property/repositories/property_repository.dart';
import 'package:hunt_property/services/favorites_sync.dart';
import 'package:hunt_property/services/shortlist_service.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/services/auth_service.dart';
import 'package:hunt_property/services/profile_service.dart';
import 'package:hunt_property/screen/filter_screen.dart';
import 'package:hunt_property/screen/search_screen.dart';
import 'package:hunt_property/services/filter_service.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;
  final String? tag;
  final String? price;
  final String? location;
  final bool initialIsFavorite;

  const PropertyDetailsScreen({
    super.key,
    required this.propertyId,
    this.tag,
    this.price,
    this.location,
    this.initialIsFavorite = false,
  });

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final ShortlistService _shortlistService = ShortlistService();
  late final PropertyCubit _propertyCubit;
  late bool _isFavorite;
  Property? _currentProperty; // latest loaded property details
  bool _favoriteSynced = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    _propertyCubit = PropertyCubit(repository: PropertyRepository());
    _propertyCubit.fetchProperty(widget.propertyId);
  }

  /// Heart state from server shortlist (source of truth for DB persistence).
  Future<void> _syncFavoriteFromShortlist() async {
    final propId = widget.propertyId.trim();
    if (propId.isEmpty) return;
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) return;

    try {
      final inList = await _shortlistService.isPropertyShortlisted(propId);
      if (!mounted) return;
      setState(() {
        _isFavorite = inList;
      });
    } catch (_) {
      // Keep current _isFavorite
    }
  }

  @override
  void dispose() {
    _propertyCubit.close();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to save favorites')),
        );
      }
      return;
    }

    final propId = widget.propertyId;
    if (propId.isEmpty) return;

    setState(() => _isFavorite = !_isFavorite); // optimistic

    bool success = false;
    if (_isFavorite) {
      success = await _shortlistService.addToShortlist(propId);
    } else {
      success = await _shortlistService.removeFromShortlist(propId);
    }

    if (!success) {
      setState(() => _isFavorite = !_isFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorites')),
        );
      }
      return;
    }

    FavoritesSync.notifyChanged();
    await _syncFavoriteFromShortlist();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
        ),
      );
    }

    try {
      final cubit = BlocProvider.of<ShortlistCubit>(context, listen: false);
      cubit.load();
    } catch (_) {}
  }

  Future<void> _shareProperty() async {
    // Try to use full property details from last loaded state
    final property = _currentProperty;

    final title = property?.title ?? widget.tag ?? 'Property';

    String priceText;
    if (property?.price != null && property!.price! > 0) {
      priceText = '₹ ${property.price!.toStringAsFixed(0)}';
    } else {
      priceText = widget.price ?? '';
    }

    String locationText;
    if (property?.location != null) {
      final loc = property!.location!;
      locationText = [
        loc.address,
        loc.locality,
        loc.city,
      ].where((s) => s != null && s.toString().trim().isNotEmpty).join(', ');
    } else {
      locationText = widget.location ?? '';
    }

    // Shareable URL (deep link / backend URL)
    final repo = PropertyRepository();
    final propertyUrl = '${repo.baseUrl}/api/properties/${widget.propertyId}';

    final detailsLines = <String>[
      'Check this property on Hunt Property:',
      if (title.isNotEmpty) title,
      if (priceText.isNotEmpty) 'Price: $priceText',
      if (locationText.isNotEmpty) 'Location: $locationText',
      if (property != null && property.areaSqft != null)
        'Area: ${_formatArea(property.areaSqft)}',
      if (property != null && property.bedrooms != null)
        'Bedrooms: ${property.bedrooms}',
      if (property != null && property.bathrooms != null)
        'Bathrooms: ${property.bathrooms}',
      if (property != null && property.transactionType.isNotEmpty)
        'For: ${property.transactionType}',
      '',
      'More details:',
      propertyUrl,
    ];

    final message =
        detailsLines.where((s) => s.trim().isNotEmpty).join('\n');

    // Try to attach main property image (WhatsApp / Telegram preview ke liye)
    XFile? imageFile;
    String? imageUrl;
    if (property != null && property.images.isNotEmpty) {
      // Prefer primary image, fallback to first
      final primary = property.images.firstWhere(
        (i) => i.isPrimary == true,
        orElse: () => property!.images.first,
      );
      imageUrl = primary.url;
    }

    if (imageUrl != null && imageUrl.startsWith('http')) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/property_${widget.propertyId}.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          imageFile = XFile(file.path);
        }
      } catch (e) {
        // Image download fail ho jaye to bhi text share chalega
        debugPrint('Share image download failed: $e');
      }
    }

    try {
      if (imageFile != null) {
        await Share.shareXFiles(
          [imageFile],
          text: message,
          subject: title,
        );
      } else {
        await Share.share(
          message,
          subject: title,
        );
      }
    } catch (e) {
      // Agar file-share me koi issue aaye to simple text share fallback
      debugPrint('Share failed with image, falling back to text: $e');
      await Share.share(
        message,
        subject: title,
      );
    }
  }

  /// Same search experience as Home / Search tab (full [SearchScreen]).
  void _openFullSearch({FilterSelection? filters}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchScreen(initialFilters: filters),
      ),
    );
  }

  /// Same filter bottom sheet as Home / Search, then opens search with selection.
  Future<void> _openFilterFromDetails() async {
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
            initialSelection: null,
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    _openFullSearch(filters: result);
  }

  Future<void> _handleContactOwner() async {
    final formResult = await _showContactOwnerFormDialog(context);
    if (formResult == null || !mounted) return;

    final scaffold = ScaffoldMessenger.of(context);
    final authService = AuthService();

    // Step 1: Request OTP
    final otpRes = await authService.requestOtp(formResult.phone);
    if (otpRes['success'] != true) {
      final msg = otpRes['error']?.toString() ?? 'Failed to send OTP';
      scaffold.showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    // Step 2: Verify OTP via dialog
    final verified = await _showOtpDialog(context: context, phone: formResult.phone);
    if (!verified || !mounted) return;

    // Step 3: Fetch owner details using ownerId from property if available
    String ownerName = 'Owner';
    String ownerEmail = 'Not available';
    String ownerPhone = 'Not available';

    final ownerId = _currentProperty?.ownerId;
    if (ownerId != null && ownerId.isNotEmpty) {
      try {
        final profileRes = await ProfileService().getProfile(ownerId);
        if (profileRes['success'] == true) {
          final data = profileRes['data'] as Map<String, dynamic>;
          ownerName = (data['name'] ??
                  data['full_name'] ??
                  data['fullName'] ??
                  data['username'] ??
                  ownerName)
              .toString();
          ownerEmail =
              (data['email'] ?? ownerEmail).toString();
          ownerPhone =
              (data['phone'] ?? data['phone_number'] ?? ownerPhone).toString();
        }
      } catch (_) {}
    }

    if (!mounted) return;
    await _showOwnerDetailsDialog(
      context: context,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      ownerPhone: ownerPhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _propertyCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: BlocBuilder<PropertyCubit, PropertyState>(
          builder: (context, state) {
            if (state is PropertyLoading || state is PropertyInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PropertyError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is PropertyLoaded) {
              // Cache latest property so share button ke time par
              // bina Bloc/Provider context ke details mil sake.
              _currentProperty = state.property;
              if (!_favoriteSynced) {
                _favoriteSynced = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _syncFavoriteFromShortlist();
                });
              }
              return SingleChildScrollView(
                child: _PropertyDetailsView(property: state.property),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        bottomNavigationBar: _buildBottomActionBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
        ),
      ),
      // Matches Home header search: same hint, tune → filter sheet, field → full Search.
      title: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () => _openFullSearch(),
                  cursorColor: AppColors.primaryColor,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Search your area, project',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openFilterFromDetails,
                child: const Icon(Icons.tune, color: Colors.grey, size: 20),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? AppColors.primaryColor : AppColors.textDark,
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.textDark),
          onPressed: _shareProperty,
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
          Text(widget.price ?? '₹ 45Lac',
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
            'For ${widget.tag ?? 'Sell'} in ${widget.location ?? 'Hyderabad, Hyderabad City'}',
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
                        widget.location ?? 'Hyderabad',
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
      {'image': 'assets/images/car_parking.png', 'label': 'Car Parking'},
      {'image': 'assets/images/Kids.png', 'label': "Kid's Playground"},
      {'image': 'assets/images/club_house.png', 'label': 'Club House'},
      {'image': 'assets/images/restro.png', 'label': 'Restaurants'},
      {'image': 'assets/images/gym.png', 'label': 'Fitness Gym'},
      {'image': 'assets/images/school.png', 'label': 'School'},
      {'image': 'assets/images/hospital.png', 'label': 'Hospital'},
      {'image': 'assets/images/swimming.png', 'label': 'Swimming Pool'},
      {'image': 'assets/images/water.png', 'label': '24 Hour Water Supply'},
      {'image': 'assets/images/fire.png', 'label': 'Firefighting'},
      {'image': 'assets/images/power_backup.png', 'label': 'Power backup'},
      {'image': 'assets/images/yoga.png', 'label': 'Yoga'},
      {'image': 'assets/images/Library.png', 'label': 'Library'},
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
          _buildDescriptionItem('Property For', widget.tag ?? 'Sell'),
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

  // removed instance helper; use file-level helper below

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
                onPressed: () {
                  _showFraudAlertDialog(context);
                },
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
                onPressed: _handleContactOwner,
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

Widget buildBottomActionBar(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _showFraudAlertDialog(context);
              },
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

class _ContactOwnerFormResult {
  final String name;
  final String email;
  final String phone;
  final String interestedIn;
  final String userType; // individual | dealer
  final bool allowSimilar;

  _ContactOwnerFormResult({
    required this.name,
    required this.email,
    required this.phone,
    required this.interestedIn,
    required this.userType,
    required this.allowSimilar,
  });
}

class _PropertyDetailsView extends StatefulWidget {
  final Property property;

  const _PropertyDetailsView({required this.property});

  @override
  State<_PropertyDetailsView> createState() => _PropertyDetailsViewState();
}

class _PropertyDetailsViewState extends State<_PropertyDetailsView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _latLng;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final coords = widget.property.location?.geo?.coordinates;
    if (coords != null && coords.length >= 2) {
      // API provides [longitude, latitude]
      final double lng = coords[0];
      final double lat = coords[1];
      // Treat (0,0) as invalid - Google Map on iOS can crash with null island
      final bool isValid = (lat != 0.0 || lng != 0.0);
      if (isValid) {
        _latLng = LatLng(lat, lng);
        debugPrint('Property coords parsed: lat=$lat, lng=$lng');
      } else {
        debugPrint('Property coords ignored (0,0) for ${widget.property.id}');
      }
    } else {
      debugPrint('No geo coordinates for property ${widget.property.id}');
    }
    // If we don't have coordinates from the API, try geocoding the address/locality/city
    if (_latLng == null) {
      final addrParts = [
        widget.property.location?.address,
        widget.property.location?.locality,
        widget.property.location?.city
      ].where((s) => s != null && s.trim().isNotEmpty).toList();
      if (addrParts.isNotEmpty) {
        _tryGeocode(addrParts.join(', '));
      }
    }
  }

  Future<void> _tryGeocode(String address) async {
    try {
      debugPrint('Attempting geocode for address: $address');
      final places = await locationFromAddress(address);
      if (places.isNotEmpty) {
        final p = places.first;
        setState(() {
          _latLng = LatLng(p.latitude, p.longitude);
        });
        debugPrint('Geocoding success: lat=${p.latitude}, lng=${p.longitude}');
      } else {
        debugPrint('Geocoding returned no results for: $address');
      }
    } catch (e) {
      debugPrint('Geocoding failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final primaryImage = property.images.isNotEmpty ? property.images.first.url : null;
    final geo = property.location?.geo;
    final latLng = _latLng;

    Widget _mapCard() {
      if (latLng != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 140,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: latLng, zoom: 13),
              markers: {Marker(markerId: const MarkerId('prop'), position: latLng)},
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) async {
                if (!_mapController.isCompleted) _mapController.complete(controller);
                try {
                  await controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
                } catch (_) {}
              },
            ),
          ),
        );
      }
      // Placeholder card with icon and locality text (matches screenshot)
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 36, color: Colors.grey.shade600),
              const SizedBox(height: 8),
              Text(
                '${property.location?.locality ?? ''} ${property.location?.city ?? ''}'.trim(),
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
      );
    }

    // Static amenity master list: image ya icon ke sath
    final List<Map<String, dynamic>> masterAmenities = [
      {'name': 'Car Parking', 'image': 'assets/images/car_parking.png'},
      {'name': "Kid's Playground", 'image': 'assets/images/Kids.png'},
      {'name': 'Club House', 'image': 'assets/images/club_house.png'},
      {'name': 'Restaurants', 'image': 'assets/images/restro.png'},
      {'name': 'Fitness Gym', 'image': 'assets/images/gym.png'},
      {'name': 'School', 'image': 'assets/images/school.png'},
      {'name': 'Hospital', 'image': 'assets/images/hospital.png'},
      {'name': 'Swimming Pool', 'image': 'assets/images/swimming.png'},
      {'name': '24 Hour Water Supply', 'image': 'assets/images/water.png'},
      {'name': 'Firefighting', 'image': 'assets/images/fire.png'},
      {'name': 'Power backup', 'image': 'assets/images/power_backup.png'},
      {'name': 'Yoga', 'image': 'assets/images/yoga.png'},
      {'name': 'Library', 'image': 'assets/images/Library.png'},
    ];

    // Backend se aaye amenities ko master list se map karo,
    // taaki sirf wohi amenities dikhain jo property me hain.
    final List<Map<String, dynamic>> displayedAmenities = [];
    for (final raw in property.amenities) {
      final key = raw.toLowerCase();
      final match = masterAmenities.firstWhere(
        (m) => key.contains(m['name'].toString().toLowerCase().split(' ').first),
        orElse: () => {},
      );
      if (match.isNotEmpty && !displayedAmenities.contains(match)) {
        displayedAmenities.add(match);
      }
    }

    // Agar backend ne amenities list khali bheji ho, to fallback: sab master dikhado
    final amenitiesToShow =
        displayedAmenities.isNotEmpty ? displayedAmenities : masterAmenities;

    String _priceText() {
      final price = property.price ?? 0;
      if (price <= 0) return '₹ 0';

      final isRent =
          property.transactionType.toLowerCase() == 'rent';
      final formatter = NumberFormat.decimalPattern('en_IN');

      if (isRent) {
        // e.g. ₹ 12,500/month
        return '₹ ${formatter.format(price)}/month';
      }

      // For sale – show in Lac / Cr like portals
      if (price >= 10000000) {
        // 1 Cr = 1,00,00,000
        final cr = price / 10000000;
        final crStr = cr % 1 == 0
            ? cr.toStringAsFixed(0)
            : cr.toStringAsFixed(1);
        return '₹ $crStr Cr';
      } else if (price >= 100000) {
        // 1 Lac = 1,00,000
        final lac = price / 100000;
        final lacStr = lac % 1 == 0
            ? lac.toStringAsFixed(0)
            : lac.toStringAsFixed(1);
        return '₹ $lacStr Lac';
      }

      // Fallback: simple currency formatting
      return '₹ ${formatter.format(price)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image carousel/banner
        SizedBox(
          height: 260,
          width: double.infinity,
          child: property.images.isEmpty
              ? Container(
                  color: AppColors.lightGray,
                  child: Center(
                    child: const Icon(Icons.home, size: 100, color: AppColors.primaryColor),
                  ),
                )
              : Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: property.images.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, i) {
                        final img = property.images[i].url;
                        return Image.network(img, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Container(color: AppColors.lightGray));
                      },
                    ),
                    Positioned(
                      bottom: 12,
                      child: Row(
                        children: List.generate(property.images.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == i ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_priceText(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(property.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text('${property.transactionType} • ${property.location?.city ?? ''}', style: const TextStyle(fontSize: 14, color: AppColors.textLight)),
            if (property.availabilityStatus.toLowerCase() == 'unavailable' ||
                property.listingStatus.toLowerCase() == 'inactive') ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4F4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD6D6)),
                ),
                child: Text(
                  _availabilityBannerText(
                    property.availabilityMessage,
                    property.removalReason,
                    property.removalNote,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ]),
        ),

        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('See Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _mapCard(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      // open external maps: prefer coords, otherwise search by address
                      if (_latLng != null) {
                        final url = 'https://www.google.com/maps/search/?api=1&query=${_latLng!.latitude},${_latLng!.longitude}';
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      } else {
                        final addr = [
                          widget.property.location?.address,
                          widget.property.location?.locality,
                          widget.property.location?.city
                        ].where((s) => s != null && s.trim().isNotEmpty).join(', ');
                        if (addr.isNotEmpty) {
                          final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addr)}';
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        }
                      }
                    },
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
            const SizedBox(height: 18),
            const Text('Amenities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            // Grid of amenity icons (4 columns) to match design
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: amenitiesToShow.length,
              itemBuilder: (context, idx) {
                final item = amenitiesToShow[idx];
                final String name = item['name'] as String;
                final String? imagePath = item['image'] as String?;
                final IconData? iconData = item['icon'] as IconData?;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: imagePath != null
                            ? Image.asset(
                                imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    Icon(iconData ?? Icons.check,
                                        size: 24,
                                        color: Colors.black54),
                              )
                            : Icon(
                                iconData ?? Icons.check,
                                size: 24,
                                color: Colors.black54,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('Key Highlight',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED)),
            const SizedBox(height: 12),
            // Highlights grid-like rows (styled)
            _highlightRow('Bedrooms', property.bedrooms?.toString() ?? '-'),
            _highlightRow('Bathrooms', property.bathrooms?.toString() ?? '-'),
            _highlightRow('Balcony', property.images.length > 1 ? 'Yes' : '-'),
            _highlightRow('Covered area', _formatArea(property.areaSqft)),
            _highlightRow('Carpet area', _formatArea(property.carpetArea)),
            _highlightRow('Plot area', _formatArea(property.plotArea)),
            _highlightRow('Furnished Status', property.furnishedStatus ?? property.furnishing ?? '-'),
            _highlightRow('Transaction type', property.transactionType),
            _highlightRow('Floor', (property.floorNumber != null && property.totalFloors != null) ? '${property.floorNumber} (Out of ${property.totalFloors})' : (property.floorNumber?.toString() ?? '-')),
            _highlightRow('Car Parking', property.amenities.any((a) => a.toLowerCase().contains('car')) ? 'Yes' : 'No'),
            _highlightRow('Lift', (property.lift == true) ? 'Yes' : 'No'),
            _highlightRow('Type of Ownership', property.typeOfOwnership ?? '-'),
            _highlightRow('Facing', property.location?.geo == null ? (property.facing ?? '-') : (property.facing ?? '-')),
            const SizedBox(height: 18),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('Property Description',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED)),
            const SizedBox(height: 10),
            Text(property.description),
            const SizedBox(height: 12),
            _buildDescriptionItem('Property For', property.transactionType),
            _buildDescriptionItem('State', '-'),
            _buildDescriptionItem('City', property.location?.city ?? '-'),
            _buildDescriptionItem('Locality', property.location?.locality ?? '-'),
            _buildDescriptionItem('Address', property.location?.address ?? '-'),
            const SizedBox(height: 12),
            SizedBox(height: 80 + MediaQuery.of(context).viewPadding.bottom),
          ]),
        ),
      ],
    );
  }
}

// File-level helper so multiple widgets/classes can reuse it
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

/// Fraud alert dialog matching the provided UI.
Future<void> _showFraudAlertDialog(BuildContext context,
    {String phoneNumber = '555-0199'}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) {
      bool agreed = false;
      return StatefulBuilder(
        builder: (ctx, setState) {
          final bool canCall = agreed;
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2FED9A),
                            width: 2,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF1FFF7),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFFFE5B5B),
                            size: 24,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        splashRadius: 20,
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Fraud Alert',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Some owners or agents may ask\nfor advance payment before a property visit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBF2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFE4B5)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Never pay any money before physically verifying the property.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hunt Property does not control financial transactions outside our platform. '
                          'Please exercise caution.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: agreed,
                        activeColor: const Color(0xFF2FED9A),
                        onChanged: (v) {
                          setState(() {
                            agreed = v ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'I understand and will not pay any\nadvance without verification',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AbsorbPointer(
                    absorbing: !canCall,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!canCall) return;
                          Navigator.of(dialogCtx).pop();
                          await _launchPhoneCall(phoneNumber);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: canCall
                              ? const Color(0xFF2FED9A)
                              : const Color(0xFFE5E7EB),
                          foregroundColor:
                              canCall ? Colors.white : const Color(0xFF9CA3AF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: canCall ? 1 : 0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.call, size: 18,color: AppColors.primaryColor,),
                                const SizedBox(width: 8),
                                Text(
                                  'Call $phoneNumber',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Verified Contact',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: canCall
                                        ? Colors.white.withOpacity(0.9)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: canCall
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _launchPhoneCall(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Future<_ContactOwnerFormResult?> _showContactOwnerFormDialog(
  BuildContext context,
) async {
  return showDialog<_ContactOwnerFormResult>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) {
      final nameController = TextEditingController();
      final emailController = TextEditingController();
      final phoneController = TextEditingController();
      String selectedInterest = '';
      String userType = 'individual';
      bool allowSimilar = true;

      final interests = <String>[
        'Immediate Purchase',
        'Site Visit',
        'Home Loan',
        'Vaastu',
        'Interior',
      ];

      return StatefulBuilder(
        builder: (ctx, setState) {
          void submit() {
            final name = nameController.text.trim();
            final email = emailController.text.trim();
            final phone = phoneController.text.trim();
            if (name.isEmpty || email.isEmpty || phone.isEmpty) {
              ScaffoldMessenger.of(dialogCtx).showSnackBar(
                const SnackBar(content: Text('Please fill all required fields')),
              );
              return;
            }
            Navigator.of(dialogCtx).pop(
              _ContactOwnerFormResult(
                name: name,
                email: email,
                phone: phone,
                interestedIn: selectedInterest,
                userType: userType,
                allowSimilar: allowSimilar,
              ),
            );
          }

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Contact Owner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        splashRadius: 20,
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please share your details to contact the Owner.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedInterest.isEmpty ? null : selectedInterest,
                    decoration: const InputDecoration(
                      labelText: 'Interested in (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: interests
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedInterest = val ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You are',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              userType = 'individual';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: userType == 'individual'
                                    ? AppColors.primaryColor
                                    : const Color(0xFFE5E7EB),
                              ),
                              color: userType == 'individual'
                                  ? const Color(0xFFEBFFF6)
                                  : Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                'Individual',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: userType == 'individual'
                                      ? Colors.black
                                      : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              userType = 'dealer';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: userType == 'dealer'
                                    ? AppColors.primaryColor
                                    : const Color(0xFFE5E7EB),
                              ),
                              color: userType == 'dealer'
                                  ? const Color(0xFFEBFFF6)
                                  : Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                'Dealer',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: userType == 'dealer'
                                      ? Colors.black
                                      : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: allowSimilar,
                        activeColor: AppColors.primaryColor,
                        onChanged: (v) {
                          setState(() {
                            allowSimilar = v ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'I agree to be contacted for similar properties',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Get Owner Details',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<bool> _showOtpDialog({
  required BuildContext context,
  required String phone,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) {
          final List<TextEditingController> ctrls =
              List.generate(4, (_) => TextEditingController());
          final List<FocusNode> nodes = List.generate(4, (_) => FocusNode());
          bool isLoading = false;
          String? errorText;

          String getOtp() =>
              ctrls.map((c) => c.text.trim()).join();

          return StatefulBuilder(
            builder: (ctx, setState) {
              Future<void> submit() async {
                final code = getOtp();
                if (code.length != 4) {
                  setState(() {
                    errorText = 'Please enter 4-digit code';
                  });
                  return;
                }
                setState(() {
                  isLoading = true;
                  errorText = null;
                });

                final res = await AuthService().verifyOtp(phone, code);
                if (res['success'] == true) {
                  Navigator.of(dialogCtx).pop(true);
                } else {
                  setState(() {
                    isLoading = false;
                    errorText =
                        res['error']?.toString() ?? 'Invalid OTP, please try again';
                  });
                }
              }

              Widget _otpBox(int index) {
                return SizedBox(
                  width: 46,
                  child: TextField(
                    controller: ctrls[index],
                    focusNode: nodes[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      if (val.length == 1 && index < 3) {
                        nodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        nodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }

              return Dialog(
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 24),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF1FFF7),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            splashRadius: 20,
                            onPressed: () => Navigator.of(dialogCtx).pop(false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 4-digit code sent to $phone',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, _otpBox),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Verify Code',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          // re-send OTP
                          await AuthService().requestOtp(phone);
                          ScaffoldMessenger.of(dialogCtx).showSnackBar(
                            const SnackBar(
                                content: Text('OTP resent successfully')),
                          );
                        },
                        child: const Text(
                          'RESEND OTP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ) ??
      false;
}

Future<void> _showOwnerDetailsDialog({
  required BuildContext context,
  required String ownerName,
  required String ownerEmail,
  required String ownerPhone,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Property Info',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    splashRadius: 18,
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Name : $ownerName',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Email id : $ownerEmail',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Mobile No : $ownerPhone',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Amenity icon helper - maps common amenity names to asset icons (falls back to Icon)
Widget _amenityIcon(String label) {
  final key = label.toLowerCase();
  String? asset;

  if (key.contains('car') || key.contains('parking')) {
    asset = 'assets/images/car_parking.png';
  } else if (key.contains('kid') || key.contains('play')) {
    asset = 'assets/images/Kids.png';
  } else if (key.contains('gym') || key.contains('fitness')) {
    asset = 'assets/images/gym.png';
  } else if (key.contains('swimm') || key.contains('pool')) {
    asset = 'assets/images/swimming_pool.png';
  } else if (key.contains('24') || key.contains('water')) {
    asset = 'assets/images/water_supply.png';
  } else if (key.contains('fire')) {
    asset = 'assets/images/fire_safety.png';
  } else if (key.contains('library')) {
    asset = 'assets/images/Library.png';
  } else if (key.contains('rest')) {
    asset = 'assets/images/restro.png';
  } else if (key.contains('club')) {
    asset = 'assets/images/club_house.png';
  } else if (key.contains('yoga')) {
    asset = 'assets/images/yoga.png';
  } else if (key.contains('power') || key.contains('backup')) {
    asset = 'assets/images/power_backup.png';
  }

  if (asset != null) {
    return Image.asset(
      asset,
      height: 24,
      width: 24,
      fit: BoxFit.contain,
    );
  }

  return const Icon(Icons.check_circle, size: 24);
}

Widget _amenityIconLarge(String label) {
  final key = label.toLowerCase();
  String? asset;
  IconData? fallbackIcon;

  if (key.contains('car') || key.contains('parking')) {
    asset = 'assets/images/car_parking.png';
    fallbackIcon = Icons.directions_car;
  } else if (key.contains('kid') || key.contains('play')) {
    asset = 'assets/images/Kids.png';
    fallbackIcon = Icons.child_care;
  } else if (key.contains('gym') || key.contains('fitness')) {
    asset = 'assets/images/gym.png';
    fallbackIcon = Icons.fitness_center;
  } else if (key.contains('swimm') || key.contains('pool')) {
    asset = 'assets/images/swimming_pool.png';
    fallbackIcon = Icons.pool;
  } else if (key.contains('24') || key.contains('water')) {
    asset = 'assets/images/water_supply.png';
    fallbackIcon = Icons.water_drop;
  } else if (key.contains('fire') || key.contains('firefight')) {
    asset = 'assets/images/fire_safety.png';
    fallbackIcon = Icons.local_fire_department;
  } else if (key.contains('library')) {
    asset = 'assets/images/Library.png';
    fallbackIcon = Icons.menu_book;
  } else if (key.contains('rest')) {
    asset = 'assets/images/restro.png';
    fallbackIcon = Icons.restaurant;
  } else if (key.contains('club')) {
    asset = 'assets/images/club_house.png';
    fallbackIcon = Icons.apartment;
  } else if (key.contains('yoga')) {
    asset = 'assets/images/yoga.png';
    fallbackIcon = Icons.self_improvement;
  } else if (key.contains('power') || key.contains('backup')) {
    asset = 'assets/images/power_backup.png';
    fallbackIcon = Icons.bolt;
  } else if (key.contains('hospital')) {
    // No custom asset in project, use Material icon
    fallbackIcon = Icons.local_hospital;
  }

  if (asset != null) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(fallbackIcon ?? Icons.check, size: 24, color: Colors.black54),
      ),
    );
  }

  return Icon(fallbackIcon ?? Icons.check, size: 24, color: Colors.black54);
}

// Highlight row styled like screenshot: left label column with pale bg, right value
Widget _highlightRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(value, textAlign: TextAlign.right, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ),
      ],
    ),
  );
}

String _formatArea(double? area) {
  if (area == null || area == 0) return '-';
  // If area is large treat as sq ft number
  if (area >= 1000) {
    return '${area.toStringAsFixed(area.truncateToDouble() == area ? 0 : 2)} Sq ft';
  }
  return '${area.toStringAsFixed(area.truncateToDouble() == area ? 0 : 2)}';
}

String _availabilityBannerText(
  String? availabilityMessage,
  String? removalReason,
  String? removalNote,
) {
  final msg = (availabilityMessage ?? '').trim();
  if (msg.isNotEmpty) return msg;

  switch ((removalReason ?? '').toLowerCase()) {
    case 'property_sold_out':
      return 'This property is marked as sold out.';
    case 'property_rent_out':
      return 'This property is marked as rented out.';
    default:
      return 'Now this property is unavailable.';
  }
}
