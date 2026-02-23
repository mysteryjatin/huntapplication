import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/cubit/property_cubit.dart';
import 'package:hunt_property/repositories/property_repository.dart';
import 'package:hunt_property/models/property.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final String propertyId;
  final String? tag;
  final String? price;
  final String? location;

  const PropertyDetailsScreen({
    super.key,
    required this.propertyId,
    this.tag,
    this.price,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PropertyCubit(repository: PropertyRepository())..fetchProperty(propertyId),
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
              return SingleChildScrollView(
                child: _PropertyDetailsView(property: state.property),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        bottomNavigationBar: buildBottomActionBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
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
          Text(price ?? '₹ 45Lac',
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

Widget buildBottomActionBar() {
  return Container(
    padding: const EdgeInsets.all(16),
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
      _latLng = LatLng(lat, lng);
      debugPrint('Property coords parsed: lat=$lat, lng=$lng');
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

    Widget _amenityChip(String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F8F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBFE6CB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _amenityIcon(label),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      );
    }

    String _priceText() {
      if (property.price != null && property.price! > 0) {
        return '₹ ${property.price!.toStringAsFixed(0)}';
      }
      return '₹ 0';
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
              itemCount: property.amenities.length,
              itemBuilder: (context, idx) {
                final a = property.amenities[idx];
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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0,2))],
                      ),
                      child: Center(child: _amenityIconLarge(a)),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        a,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w600),
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
  if (key.contains('car') || key.contains('parking')) asset = 'assets/images/car_parking.png';
  else if (key.contains('kid') || key.contains('play')) asset = 'assets/images/Kids.png';
  else if (key.contains('gym') || key.contains('fitness')) asset = 'assets/images/gym.png';
  else if (key.contains('swimm') || key.contains('pool')) asset = 'assets/images/swimming_pool.png';
  else if (key.contains('24') || key.contains('water')) asset = 'assets/images/water_supply.png';
  else if (key.contains('fire') || key.contains('firefight')) asset = 'assets/images/fire_safety.png';
  else if (key.contains('library')) asset = 'assets/images/Library.png';
  else if (key.contains('rest')) asset = 'assets/images/restro.png';
  else if (key.contains('club')) asset = 'assets/images/club_house.png';
  else if (key.contains('yoga')) asset = 'assets/images/yoga.png';
  else if (key.contains('power') || key.contains('backup')) asset = 'assets/images/power_backup.png';

  if (asset != null) {
    return SizedBox(width: 36, height: 36, child: Image.asset(asset, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.check, size: 24)));
  }
  return const Icon(Icons.check, size: 24, color: Colors.black54);
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

