// add_post_step2_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/add_post_step3_screen.dart';
import 'package:hunt_property/models/property_models.dart';
import 'package:hunt_property/models/property_field_config.dart';
import 'package:url_launcher/url_launcher.dart';
class AddPostStep2Screen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final PropertyDraft draft;

  const AddPostStep2Screen({super.key, this.onBackPressed, required this.draft});

  @override
  State<AddPostStep2Screen> createState() => _AddPostStep2ScreenState();
}

class _AddPostStep2ScreenState extends State<AddPostStep2Screen> {
  Color get _primary => AppColors.primaryColor;

  // ===================== State variables =====================
  String? _selectedState;
  String? _selectedCity;

  // Indian states and union territories (alphabetical)
  final List<String> _states = const [
    'Andaman and Nicobar Islands',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chandigarh',
    'Chhattisgarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu and Kashmir',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Ladakh',
    'Lakshadweep',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Puducherry',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  final Map<String, List<String>> _citiesByState = const {
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Tirupati'],
    'Arunachal Pradesh': ['Itanagar', 'Naharlagun'],
    'Assam': ['Guwahati', 'Dibrugarh', 'Silchar'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur'],
    'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur'],
    'Goa': ['Panaji', 'Vasco da Gama', 'Margao'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'],
    'Haryana': ['Gurugram', 'Faridabad', 'Panipat', 'Karnal'],
    'Himachal Pradesh': ['Shimla', 'Dharamshala', 'Mandi'],
    'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Mangaluru', 'Hubballi'],
    'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik'],
    'Manipur': ['Imphal'],
    'Meghalaya': ['Shillong'],
    'Mizoram': ['Aizawl'],
    'Nagaland': ['Dimapur', 'Kohima'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
    'Rajasthan': ['Jaipur', 'Udaipur', 'Jodhpur', 'Kota'],
    'Sikkim': ['Gangtok'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli'],
    'Telangana': ['Hyderabad', 'Warangal', 'Karimnagar'],
    'Tripura': ['Agartala'],
    'Uttar Pradesh': [
      'Agra',
      'Aligarh',
      'Ambedkar Nagar',
      'Amethi',
      'Amroha',
      'Auraiya',
      'Azamgarh',
      'Baghpat',
      'Bahraich',
      'Ballia',
      'Balrampur',
      'Banda',
      'Barabanki',
      'Bareilly',
      'Basti',
      'Bijnor',
      'Budaun',
      'Bulandshahr',
      'Chandauli',
      'Chitrakoot',
      'Deoria',
      'Etah',
      'Etawah',
      'Farrukhabad',
      'Fatehpur',
      'Firozabad',
      'Noida',
      'Greater Noida',
      'Ghaziabad',
      'Gonda',
      'Gorakhpur',
      'Hamirpur',
      'Hardoi',
      'Hathras',
      'Jalaun',
      'Jaunpur',
      'Jhansi',
      'Kannauj',
      'Kanpur',
      'Kasganj',
      'Kaushambi',
      'Kushinagar',
      'Lakhimpur Kheri',
      'Lalitpur',
      'Lucknow',
      'Maharajganj',
      'Mahoba',
      'Mainpuri',
      'Mathura',
      'Mau',
      'Meerut',
      'Mirzapur',
      'Moradabad',
      'Muzaffarnagar',
      'Pilibhit',
      'Pratapgarh',
      'Prayagraj (Allahabad)',
      'Rae Bareli',
      'Rampur',
      'Saharanpur',
      'Sambhal',
      'Sant Kabir Nagar',
      'Shahjahanpur',
      'Shamli',
      'Shravasti',
      'Sitapur',
      'Sonbhadra',
      'Sultanpur',
      'Unnao',
      'Varanasi'
    ],
    'Uttarakhand': ['Dehradun', 'Haridwar', 'Rishikesh'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Siliguri'],
    'Andaman and Nicobar Islands': ['Port Blair'],
    'Chandigarh': ['Chandigarh'],
    'Dadra and Nagar Haveli and Daman and Diu': ['Silvassa', 'Daman'],
    'Delhi': ['New Delhi', 'Dwarka', 'Rohini', 'Saket'],
    'Jammu and Kashmir': ['Srinagar', 'Jammu'],
    'Ladakh': ['Leh', 'Kargil'],
    'Lakshadweep': ['Kavaratti'],
    'Puducherry': ['Puducherry', 'Karaikal'],
  };

  final _localityController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _buildingNameController = TextEditingController();

  int _bedrooms = 4;
  int _bathrooms = 3;
  int _balconies = 3;

  String _furnishing = "Furnished";

  final _floorNumberController = TextEditingController();
  final _totalFloorsController = TextEditingController();
  final _floorsAllowedController = TextEditingController();
  final _openSidesController = TextEditingController(); // ★ Open Sides text-field

  String _selectedFacing = "East";

  // Map related state
  LatLng? _mapPosition;
  GoogleMapController? _mapController;
  bool _mapLoading = false;

  bool _storeRoom = true;
  bool _servantRoom = true;
  bool _boundaryWallMade = false;
  String _occupancy = "";
  bool _attachedBathroom = false;
  String _electricity = "";
  bool _anyConstructionDone = false;
  String _monthlyRent = "";
  bool _sharedOfficeSpace = false;
  bool _personalWashroom = false;
  bool _pantry = false;
  String _howOldIsPG = "";
  bool _attachedBalcony = false;
  String _securityAmount = "";
  bool _commonArea = false;
  String _tenantsYouPrefer = "";
  String _laundry = "";

  final _superAreaController = TextEditingController();
  final _builtUpAreaController = TextEditingController();
  final _carpetAreaController = TextEditingController();

  // Area validation state
  String? _areaErrorMessage;
  bool _superAreaHasError = false;
  bool _builtUpAreaHasError = false;
  bool _carpetAreaHasError = false;

  String _transactionType = "New Property";
  String _possessionStatus = "Under Construction";
  String _availableFrom = "After 1 Month";
  String _ageOfConstruction = "New Construction";

  bool _carParking = true;
  bool _lift = true;

  String _ownershipType = "Freehold";

  // Preview labels for price fields (e.g. "₹ 50 Lac")
  String _expectedPricePreview = '';
  String _bookingAmountPreview = '';

  final _expectedPriceController = TextEditingController();
  final _bookingAmountController = TextEditingController();
  final _maintenanceChargesController = TextEditingController();
  final _brokerageController = TextEditingController(text: "0");
  final _unitNumberController = TextEditingController();
  final _electricityController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _securityAmountController = TextEditingController();
  final _laundryController = TextEditingController();

  static const double _outerPadding = 16;
  static const double _cardPadding = 18;
  static const double _rowGap = 16;

  @override
  void initState() {
    super.initState();
    // Initialize values from draft
    _bedrooms = widget.draft.bedrooms > 0 ? widget.draft.bedrooms : _bedrooms;
    _bathrooms = widget.draft.bathrooms > 0 ? widget.draft.bathrooms : _bathrooms;
    _balconies = widget.draft.balconies > 0 ? widget.draft.balconies : _balconies;
    _furnishing = widget.draft.furnishing.isNotEmpty ? widget.draft.furnishing : _furnishing;
    _storeRoom = widget.draft.storeRoom;
    _servantRoom = widget.draft.servantRoom;
    _boundaryWallMade = widget.draft.boundaryWallMade;
    _occupancy = widget.draft.occupancy.isNotEmpty ? widget.draft.occupancy : _occupancy;
    _attachedBathroom = widget.draft.attachedBathroom;
    _anyConstructionDone = widget.draft.anyConstructionDone;
    if (widget.draft.electricity.isNotEmpty) {
      _electricityController.text = widget.draft.electricity;
      _electricity = widget.draft.electricity;
    }
    if (widget.draft.monthlyRent.isNotEmpty) {
      _monthlyRentController.text = widget.draft.monthlyRent;
      _monthlyRent = widget.draft.monthlyRent;
    }
    if (widget.draft.expectedPrice.isNotEmpty) {
      _expectedPriceController.text = widget.draft.expectedPrice;
    }
    _sharedOfficeSpace = widget.draft.sharedOfficeSpace;
    _personalWashroom = widget.draft.personalWashroom;
    _pantry = widget.draft.pantry;
    _howOldIsPG = widget.draft.howOldIsPG.isNotEmpty ? widget.draft.howOldIsPG : _howOldIsPG;
    _attachedBalcony = widget.draft.attachedBalcony;
    _commonArea = widget.draft.commonArea;
    if (widget.draft.securityAmount.isNotEmpty) {
      _securityAmountController.text = widget.draft.securityAmount;
      _securityAmount = widget.draft.securityAmount;
    }
    _tenantsYouPrefer = widget.draft.tenantsYouPrefer.isNotEmpty ? widget.draft.tenantsYouPrefer : _tenantsYouPrefer;
    if (widget.draft.laundry.isNotEmpty) {
      _laundryController.text = widget.draft.laundry;
      _laundry = widget.draft.laundry;
    }
    
    if (widget.draft.floorNumber > 0) {
      _floorNumberController.text = widget.draft.floorNumber.toString();
    }
    if (widget.draft.totalFloors > 0) {
      _totalFloorsController.text = widget.draft.totalFloors.toString();
    }
    if (widget.draft.floorsAllowed > 0) {
      _floorsAllowedController.text = widget.draft.floorsAllowed.toString();
    }
    if (widget.draft.openSides > 0) {
      _openSidesController.text = widget.draft.openSides.toString();
    }
    if (widget.draft.areaSqft > 0) {
      _superAreaController.text = widget.draft.areaSqft.toString();
    }
    if (widget.draft.facing.isNotEmpty) {
      _selectedFacing = widget.draft.facing;
    }
    if (widget.draft.buildingName.isNotEmpty) {
      _buildingNameController.text = widget.draft.buildingName;
    }
    if (widget.draft.unitNumber.isNotEmpty) {
      _unitNumberController.text = widget.draft.unitNumber;
    }

    // Set bedrooms to 0 if property type doesn't require it
    final config = PropertyFieldConfig.getConfigForSubtype(
      widget.draft.propertySubtype,
      transactionType: widget.draft.transactionType,
    );
    if (!config.showBedrooms) {
      _bedrooms = 0;
    }
    // If draft already has address/locality/city, attempt to load map preview
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasAddress = widget.draft.address.isNotEmpty ||
          widget.draft.locality.isNotEmpty ||
          widget.draft.city.isNotEmpty;
      if (hasAddress) {
        _loadMapForAddress();
      }
    });
    // If draft contains city but state not set, try to infer state from our cities map
    if (widget.draft.city.isNotEmpty && (_selectedState == null || _selectedState!.isEmpty)) {
      final detectedCity = widget.draft.city;
      String matchedState = '';
      String matchedCity = detectedCity;
      // Try exact match first, then more fuzzy matches
      _citiesByState.forEach((state, cities) {
        for (var c in cities) {
          final lc = c.toLowerCase();
          final tk = detectedCity.toLowerCase();
          if (lc == tk || lc.contains(tk) || tk.contains(lc) || lc.startsWith(tk) || tk.startsWith(lc)) {
            if (matchedState.isEmpty) {
              matchedState = state;
              matchedCity = c;
              break;
            }
          }
        }
      });
      if (matchedState.isNotEmpty) {
        _selectedState = matchedState;
        _selectedCity = matchedCity;
      } else {
        // If no exact match, still set selectedCity so it appears in dropdown helper in build
        _selectedCity = detectedCity;
      }
    }
  }

  @override
  void dispose() {
    _localityController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _buildingNameController.dispose();
    _floorNumberController.dispose();
    _totalFloorsController.dispose();
    _floorsAllowedController.dispose();
    _openSidesController.dispose();
    _superAreaController.dispose();
    _builtUpAreaController.dispose();
    _carpetAreaController.dispose();
    _expectedPriceController.dispose();
    _bookingAmountController.dispose();
    _maintenanceChargesController.dispose();
    _brokerageController.dispose();
    _unitNumberController.dispose();
    _electricityController.dispose();
    _monthlyRentController.dispose();
    _securityAmountController.dispose();
    _laundryController.dispose();
    super.dispose();
  }

  // Get field configuration based on property subtype
  PropertyFieldConfig get _fieldConfig {
    return PropertyFieldConfig.getConfigForSubtype(
      widget.draft.propertySubtype,
      transactionType: widget.draft.transactionType,
    );
  }

  // ------------------------------ MAIN UI ------------------------------
  @override
  Widget build(BuildContext context) {
    // Debug: Print property subtype to verify it's being passed correctly
    // ignore: avoid_print
    print('📋 Property Subtype: "${widget.draft.propertySubtype}"');
    print('📋 Property Category: "${widget.draft.propertyCategory}"');
    print('📋 Field Config - Bedrooms: ${_fieldConfig.showBedrooms}, Bathrooms: ${_fieldConfig.showBathrooms}, OpenSides: ${_fieldConfig.showOpenSides}');

    // Initialise from draft once when screen builds
    _selectedCity ??= widget.draft.city.isNotEmpty ? widget.draft.city : _selectedCity;
    if (_localityController.text.isEmpty && widget.draft.locality.isNotEmpty) {
      _localityController.text = widget.draft.locality;
    }
    if (_addressController.text.isEmpty && widget.draft.address.isNotEmpty) {
      _addressController.text = widget.draft.address;
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: _buildTopBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_outerPadding),
          child: Column(
            children: [
              _locationSection(),
              const SizedBox(height: 20),
              _propertyFeaturesSection(),
              const SizedBox(height: 20),
              _areaSection(),
              const SizedBox(height: 20),
              _transactionSection(),
              const SizedBox(height: 20),
              _priceSection(),
              const SizedBox(height: 20),
              _amenitiesFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== TOP BAR =====================
  AppBar _buildTopBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
      title: Column(
        children: [
          Text("Property Location & Features",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          Text("Step 2 of 4",
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textLight)),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black),
        )
      ],
    );
  }

  // ===================== LOCATION SECTION =====================
  Widget _locationSection() {
    return _sectionCard(
      icon: Icons.location_on_outlined,
      title: "Location",
      children: [
        _label("State"),
        const SizedBox(height: 8),
        _dropdown(
          "Select State",
          _selectedState,
          List<String>.from(_states)..sort(),
          (v) => setState(() {
            _selectedState = v;
            _selectedCity = null;
          }),
        ),
        const SizedBox(height: _rowGap),

        _label("City"),
        const SizedBox(height: 8),
        _dropdown(
          "Select City",
          _selectedCity,
          _selectedState != null
              ? (() {
                  final list = List<String>.from(_citiesByState[_selectedState] ?? []);
                  final unique = list.toSet().toList();
                  // If a detected city is set but not present in our canonical list,
                  // include it so the dropdown can display it.
                  if (_selectedCity != null &&
                      _selectedCity!.isNotEmpty &&
                      !unique.any((c) => c.toLowerCase() == _selectedCity!.toLowerCase())) {
                    unique.insert(0, _selectedCity!);
                  }
                  unique.sort();
                  return unique;
                })()
              : <String>[],
          (v) {
            setState(() => _selectedCity = v);
            // Jab user city manually select kare, turant map ke liye
            // geocoding chala do taaki preview dikh sake.
            _loadMapForAddress();
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _detectMyLocation,
            icon: Icon(Icons.my_location, color: _primary),
            label: Text("Detect my location",
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: _rowGap),

        _label("Locality"),
        const SizedBox(height: 8),
        _textField(_localityController, hint: "Enter locality"),
        const SizedBox(height: _rowGap),

        _label("Address"),
        const SizedBox(height: 8),
        _textField(_addressController, hint: "Enter address"),
        const SizedBox(height: _rowGap),

        _label("Landmark"),
        const SizedBox(height: 8),
        _textField(_landmarkController, hint: "Enter landmark"),
        const SizedBox(height: _rowGap),

        _label("Map"),
        const SizedBox(height: 8),
        _mapBox(),
      ],
    );
  }

  // ===================== PROPERTY FEATURES =====================
  Widget _propertyFeaturesSection() {
    final config = _fieldConfig;
    final List<Widget> children = [];

    if (config.showBuildingName) {
      children.addAll([
        _label("Building Name"),
        const SizedBox(height: 8),
        _textField(_buildingNameController, hint: "Enter building name"),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showBedrooms) {
      children.addAll([
        _label("Bedrooms"),
        const SizedBox(height: 8),
        _numberSelectorWithCustom(selected: _bedrooms, onSelect: (v) => setState(() => _bedrooms = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showBathrooms) {
      children.addAll([
        _label("Bathrooms"),
        const SizedBox(height: 8),
        _numberSelectorWithCustom(selected: _bathrooms, onSelect: (v) => setState(() => _bathrooms = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showBalconies) {
      children.addAll([
        _label("Balconies"),
        const SizedBox(height: 8),
        _numberSelectorWithCustom(selected: _balconies, onSelect: (v) => setState(() => _balconies = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showFurnishing) {
      children.addAll([
        _label("Furnishing"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _chip("Furnished", _furnishing == "Furnished",
                        () => setState(() => _furnishing = "Furnished")),
                const SizedBox(width: 12),
                _chip("Unfurnished", _furnishing == "Unfurnished",
                        () => setState(() => _furnishing = "Unfurnished")),
              ],
            ),
            _chip("Semi-furnished", _furnishing == "Semi-furnished",
                    () => setState(() => _furnishing = "Semi-furnished")),
          ],
        ),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showTotalFloors || config.showFloorsAllowed) {
      // Move Total Floors higher than Floor Number per UI request.
      children.add(
        Row(
          children: [
            if (config.showTotalFloors)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Total Floors"),
                    const SizedBox(height: 8),
                    _textField(
                      _totalFloorsController,
                      hint: "Eg. 20",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) {
                        final enteredTotal = int.tryParse(v) ?? 0;
                        final currentFloor = int.tryParse(_floorNumberController.text) ?? 0;
                        if (enteredTotal > 0 && currentFloor > enteredTotal) {
                          // If total lowered below current floor, clamp floor number to total.
                          _floorNumberController.text = enteredTotal.toString();
                          _floorNumberController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _floorNumberController.text.length));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Total floors is less than floor number — floor number adjusted')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            if (config.showTotalFloors && config.showFloorsAllowed)
              const SizedBox(width: 12),
            if (config.showFloorsAllowed)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Floors Allowed"),
                    const SizedBox(height: 8),
                    _textField(_floorsAllowedController, hint: "Eg. 15", keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  ],
                ),
              ),
          ],
        ),
      );
      children.add(const SizedBox(height: 20));
    }

    if (config.showFloorNumber) {
      children.addAll([
        _label("Floor Number"),
        const SizedBox(height: 8),
        _textField(
          _floorNumberController,
          hint: "Eg. 12",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            final enteredFloor = int.tryParse(v) ?? 0;
            final enteredTotal = int.tryParse(_totalFloorsController.text) ?? 0;
            if (enteredTotal > 0 && enteredFloor > enteredTotal) {
              // Prevent entering a floor number greater than total floors:
              // reset to total and notify user.
              _floorNumberController.text = enteredTotal.toString();
              _floorNumberController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _floorNumberController.text.length));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Floor number cannot be greater than total floors')),
              );
            }
          },
        ),
        const SizedBox(height: 20),
      ]);
    }

    // (Moved: Total Floors and Floors Allowed are shown earlier above Floor Number)

    if (config.showAnyConstructionDone) {
      children.addAll([
        _label("Any Construction Done"),
        const SizedBox(height: 8),
        _yesNo(_anyConstructionDone, (v) => setState(() => _anyConstructionDone = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showOpenSides) {
      children.addAll([
        _label("Open Sides"),
        const SizedBox(height: 8),
        _textField(_openSidesController, hint: "Eg. 2"),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showFacing) {
      children.addAll([
        _label("Facing of Property"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _directionChip("North"),
            _directionChip("East"),
            _directionChip("South"),
            _directionChip("West"),
            _directionChip("North-East"),
            _directionChip("South-East"),
            _directionChip("South-West"),
            _directionChip("North-West"),
          ],
        ),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showAttachedBathroom) {
      children.addAll([
        _label("Attached Bathroom"),
        const SizedBox(height: 8),
        _yesNo(_attachedBathroom, (v) => setState(() => _attachedBathroom = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showSharedOfficeSpace) {
      children.addAll([
        _label("Shared Office Space"),
        const SizedBox(height: 8),
        _yesNo(_sharedOfficeSpace, (v) => setState(() => _sharedOfficeSpace = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showPersonalWashroom) {
      children.addAll([
        _label("Personal Washroom"),
        const SizedBox(height: 8),
        _yesNo(_personalWashroom, (v) => setState(() => _personalWashroom = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showPantry) {
      children.addAll([
        _label("Pantry"),
        const SizedBox(height: 8),
        _yesNo(_pantry, (v) => setState(() => _pantry = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showHowOldIsPG) {
      children.addAll([
        _label("How Old is PG"),
        const SizedBox(height: 8),
        _dropdown(
          "Select age",
          _howOldIsPG.isEmpty ? null : _howOldIsPG,
          ['Less than 1 year', '1-2 years', '2-5 years', '5-10 years', 'More than 10 years'],
          (v) => setState(() => _howOldIsPG = v ?? ''),
        ),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showAttachedBalcony) {
      children.addAll([
        _label("Attached Balcony"),
        const SizedBox(height: 8),
        _yesNo(_attachedBalcony, (v) => setState(() => _attachedBalcony = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showCommonArea) {
      children.addAll([
        _label("Common Area"),
        const SizedBox(height: 8),
        _yesNo(_commonArea, (v) => setState(() => _commonArea = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showStoreRoom) {
      children.addAll([
        _label("Store Room"),
        const SizedBox(height: 8),
        _yesNo(_storeRoom, (v) => setState(() => _storeRoom = v)),
        const SizedBox(height: 20),
      ]);
    }

    if (config.showServantRoom) {
      children.addAll([
        _label("Servant Room"),
        const SizedBox(height: 8),
        _yesNo(_servantRoom, (v) => setState(() => _servantRoom = v)),
      ]);
    }

    if (config.showBoundaryWallMade) {
      children.addAll([
        const SizedBox(height: 20),
        _label("Boundary Wall Made"),
        const SizedBox(height: 8),
        _yesNo(_boundaryWallMade, (v) => setState(() => _boundaryWallMade = v)),
      ]);
    }

    if (config.showOccupancy) {
      children.addAll([
        const SizedBox(height: 20),
        _label("Occupancy"),
        const SizedBox(height: 8),
        _dropdown(
          "Select Occupancy",
          _occupancy.isEmpty ? null : _occupancy,
          ['Owner', 'Tenant', 'Vacant', 'Under Construction'],
          (v) => setState(() => _occupancy = v ?? ''),
        ),
      ]);
    }

    if (config.showTenantsYouPrefer) {
      children.addAll([
        const SizedBox(height: 20),
        _label("Tenants You Prefer"),
        const SizedBox(height: 8),
        _dropdown(
          "Select Tenants You Prefer",
          _tenantsYouPrefer.isEmpty ? null : _tenantsYouPrefer,
          ['Professional', 'Student', 'Both'],
          (v) => setState(() => _tenantsYouPrefer = v ?? ''),
        ),
      ]);
    }

    // Only show section if there are any fields to display
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      icon: Icons.home_filled,
      title: "Property Features",
      children: children,
    );
  }

  // ===================== NUMBER SELECTOR WITH CUSTOM =====================
  Widget _numberSelectorWithCustom({
    required int selected,
    required Function(int) onSelect,
  }) {
    final fixed = List.generate(9, (i) => i + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...fixed.map((n) => _circleOption(
              label: "$n",
              active: selected == n,
              onTap: () => onSelect(n),
            )),
            _circleOption(
              label: "10+",
              active: selected > 9,
              onTap: () => onSelect(10),
            )
          ],
        ),

        if (selected > 9) ...[
          const SizedBox(height: 12),
          _textField(
            TextEditingController(text: selected.toString()),
            hint: "Enter value",
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final val = int.tryParse(v);
              if (val != null && val > 9) onSelect(val);
            },
          ),
        ],
      ],
    );
  }

  Widget _circleOption({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 42,
        decoration: BoxDecoration(
          color: active ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: active ? _primary : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.black : Colors.black87)),
        ),
      ),
    );
  }

  // ===================== AREA SECTION =====================
  Widget _areaSection() {
    final config = _fieldConfig;
    final List<Widget> children = [];

    if (config.showAreaSuper) {
      children.addAll([
        _label("Super Area (Sq. Ft)"),
        const SizedBox(height: 8),
        _textField(
          _superAreaController,
          hint: "Enter area",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => _onAreaChanged(),
          isError: _superAreaHasError,
        ),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showAreaBuiltUp) {
      children.addAll([
        _label("Built Up Area (Sq. Ft)"),
        const SizedBox(height: 8),
        _textField(
          _builtUpAreaController,
          hint: "Enter area",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => _onAreaChanged(),
          isError: _builtUpAreaHasError,
        ),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showAreaCarpet) {
      children.addAll([
        _label("Carpet Area (Sq. Ft)"),
        const SizedBox(height: 8),
        _textField(
          _carpetAreaController,
          hint: "Enter area",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => _onAreaChanged(),
          isError: _carpetAreaHasError,
        ),
      ]);
    }

    if (_areaErrorMessage != null && _areaErrorMessage!.isNotEmpty) {
      children.addAll([
        const SizedBox(height: 8),
        Text(
          _areaErrorMessage!,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ]);
    }

    // Only show section if there are any fields to display
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      icon: Icons.square_foot,
      title: "Area",
      children: children,
    );
  }

  // Validate area fields according to rule: Carpet ≤ Built‑up ≤ Super
  bool _validateAreaValues({bool hardValidation = false}) {
    final config = _fieldConfig;

    double? superArea = config.showAreaSuper
        ? double.tryParse(_superAreaController.text.trim())
        : null;
    double? builtUpArea = config.showAreaBuiltUp
        ? double.tryParse(_builtUpAreaController.text.trim())
        : null;
    double? carpetArea = config.showAreaCarpet
        ? double.tryParse(_carpetAreaController.text.trim())
        : null;

    // Reset previous error state
    _areaErrorMessage = null;
    _superAreaHasError = false;
    _builtUpAreaHasError = false;
    _carpetAreaHasError = false;

    // If user has not entered enough values yet, treat as valid in real‑time mode
    if (!hardValidation) {
      // Only run validation when at least the pair of fields involved has values
      if (carpetArea == null || builtUpArea == null) {
        if (builtUpArea == null || superArea == null) {
          return true;
        }
      }
    }

    // Rule 1: Carpet ≤ Built‑up
    if (carpetArea != null &&
        builtUpArea != null &&
        carpetArea > builtUpArea) {
      _areaErrorMessage =
          "Carpet Area cannot be greater than Built-up Area";
      _carpetAreaHasError = true;
      return false;
    }

    // Rule 2: Built‑up ≤ Super
    if (builtUpArea != null &&
        superArea != null &&
        builtUpArea > superArea) {
      _areaErrorMessage =
          "Built-up Area cannot be greater than Super Area";
      _builtUpAreaHasError = true;
      return false;
    }

    // If we reach here, values respect Carpet ≤ Built‑up ≤ Super
    return true;
  }

  void _onAreaChanged() {
    setState(() {
      _validateAreaValues();
    });
  }

  // ===================== TRANSACTION SECTION =====================
  Widget _transactionSection() {
    final config = _fieldConfig;
    final List<Widget> children = [];

    if (config.showTransactionType) {
      children.addAll([
        _label("Transaction Type"),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _toggle("New Property", _transactionType == "New Property",
                        () => setState(() => _transactionType = "New Property"))),
            const SizedBox(width: 12),
            Expanded(
                child: _toggle("Resale", _transactionType == "Resale",
                        () => setState(() => _transactionType = "Resale"))),
          ],
        ),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showPossessionStatus) {
      children.addAll([
        _label("Possession Status"),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _toggle("Under Construction",
                    _possessionStatus == "Under Construction",
                        () => setState(() => _possessionStatus = "Under Construction"))),
            const SizedBox(width: 12),
            Expanded(
                child: _toggle("Ready to move",
                    _possessionStatus == "Ready to move",
                        () => setState(() => _possessionStatus = "Ready to move"))),
          ],
        ),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showAvailableFrom) {
      children.addAll([
        _label("Available From"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _chip("Immediately", _availableFrom == "Immediately",
                    () => setState(() => _availableFrom = "Immediately")),
            const SizedBox(width: 8),
            _chip("After 1 Month", _availableFrom == "After 1 Month",
                    () => setState(() => _availableFrom = "After 1 Month")),
            _chip("After 3 Month", _availableFrom == "After 3 Month",
                    () => setState(() => _availableFrom = "After 3 Month")),
            _chip("After 7 Month", _availableFrom == "After 7 Month",
                    () => setState(() => _availableFrom = "After 7 Month")),
            _chip("After 9 Month", _availableFrom == "After 9 Month",
                    () => setState(() => _availableFrom = "After 9 Month")),
          ],
        ),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showAgeOfConstruction) {
      children.addAll([
        _label("Age of Construction"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _chip("New Construction", _ageOfConstruction == "New Construction",
                    () => setState(() => _ageOfConstruction = "New Construction")),
            _chip("Less than 5 yrs", _ageOfConstruction == "Less than 5 yrs",
                    () => setState(() => _ageOfConstruction = "Less than 5 yrs")),
            _chip("10 to 15 yrs", _ageOfConstruction == "10 to 15 yrs",
                    () => setState(() => _ageOfConstruction = "10 to 15 yrs")),
            _chip("15 to 20 yrs", _ageOfConstruction == "15 to 20 yrs",
                    () => setState(() => _ageOfConstruction = "15 to 20 yrs")),
          ],
        ),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showCarParking) {
      children.addAll([
        _label("Car Parking"),
        const SizedBox(height: 8),
        _yesNo(_carParking, (v) => setState(() => _carParking = v)),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showLift) {
      children.addAll([
        _label("Lift"),
        const SizedBox(height: 8),
        _yesNo(_lift, (v) => setState(() => _lift = v)),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showOwnershipType) {
      children.addAll([
        _label("Type of Ownership"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _chip("Freehold", _ownershipType == "Freehold",
                    () => setState(() => _ownershipType = "Freehold")),
            _chip("Leasehold", _ownershipType == "Leasehold",
                    () => setState(() => _ownershipType = "Leasehold")),
            _chip("Power of Attorney",
                _ownershipType == "Power of Attorney",
                    () => setState(() => _ownershipType = "Power of Attorney")),
          ],
        ),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showUnitNumber) {
      children.addAll([
        _label("Unit Number"),
        const SizedBox(height: 8),
        _textField(_unitNumberController, hint: "Enter unit number"),
      ]);
    }

    // Only show section if there are any fields to display
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      icon: Icons.swap_horiz_outlined,
      title: "Transaction Type",
      children: children,
    );
  }

  String _formatExpectedPriceLabel(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return '';
    final value = int.tryParse(cleaned) ?? 0;
    if (value <= 0) return '';

    return '₹ ${_numberToWordsIndian(value)}';
  }

  // Convert number to words using Indian system (Thousand / Lakh / Crore)
  // Supports values comfortably beyond 300 Crore.
  String _numberToWordsIndian(int number) {
    if (number == 0) return 'Zero';

    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];

    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    String twoDigits(int n) {
      if (n < 20) return ones[n];
      final t = n ~/ 10;
      final o = n % 10;
      if (o == 0) return tens[t];
      return '${tens[t]} ${ones[o]}';
    }

    String threeDigits(int n) {
      final h = n ~/ 100;
      final rest = n % 100;
      if (h == 0) return twoDigits(rest);
      if (rest == 0) return '${ones[h]} Hundred';
      return '${ones[h]} Hundred ${twoDigits(rest)}';
    }

    final parts = <String>[];

    final crore = number ~/ 10000000;
    if (crore > 0) {
      // Use threeDigits so we can represent values like
      // "One Hundred Crore", "Three Hundred Crore" etc.
      if (crore < 100) {
        parts.add('${twoDigits(crore)} Crore');
      } else {
        parts.add('${threeDigits(crore)} Crore');
      }
      number %= 10000000;
    }

    final lakh = number ~/ 100000;
    if (lakh > 0) {
      parts.add('${twoDigits(lakh)} Lakh');
      number %= 100000;
    }

    final thousand = number ~/ 1000;
    if (thousand > 0) {
      parts.add('${twoDigits(thousand)} Thousand');
      number %= 1000;
    }

    final hundreds = number;
    if (hundreds > 0) {
      parts.add(threeDigits(hundreds));
    }

    return parts.join(' ');
  }

  // ===================== PRICE SECTION =====================
  Widget _priceSection() {
    final config = _fieldConfig;
    final List<Widget> children = [];

    // Only show Expected Price if Monthly Rent is not shown
    if (!config.showMonthlyRent) {
      children.addAll([
        _label("Expected Price"),
        const SizedBox(height: 8),
        _textField(
          _expectedPriceController,
          hint: "Enter expected price",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            setState(() {
              _expectedPricePreview = _formatExpectedPriceLabel(v);
            });
          },
        ),
        if (_expectedPricePreview.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _expectedPricePreview,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: _rowGap),
      ]);
    }

    // Only show Booking Amount if Monthly Rent is not shown (for Sell, not Rent)
    if (!config.showMonthlyRent) {
      children.addAll([
        _label("Booking Amount"),
        const SizedBox(height: 8),
        _textField(
          _bookingAmountController,
          hint: "Enter booking amount",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            setState(() {
              _bookingAmountPreview = _formatExpectedPriceLabel(v);
            });
          },
        ),
        if (_bookingAmountPreview.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _bookingAmountPreview,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showMonthlyRent) {
      children.addAll([
        _label("Monthly Rent (₹/month)"),
        const SizedBox(height: 8),
        _textField(_monthlyRentController, hint: "Enter monthly rent", keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], suffixText: "/month"),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showSecurityAmount) {
      children.addAll([
        _label("Security Amount"),
        const SizedBox(height: 8),
        _textField(_securityAmountController, hint: "Enter security amount", keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        const SizedBox(height: _rowGap),
      ]);
    }

    if (config.showMaintenanceCharges) {
      children.addAll([
        _label("Maintenance Charges"),
        const SizedBox(height: 8),
        _textField(_maintenanceChargesController, hint: "Enter maintenance charges", keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        const SizedBox(height: _rowGap),
      ]);
    }

    children.addAll([
      _label("Brokerage"),
      const SizedBox(height: 8),
      _textField(_brokerageController, hint: "Enter brokerage", keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
    ]);

    if (config.showLaundry) {
      children.addAll([
        const SizedBox(height: _rowGap),
        _label("Laundry"),
        const SizedBox(height: 8),
        _textField(
          _laundryController,
          hint: "Enter laundry details",
          onChanged: (v) => setState(() => _laundry = v),
        ),
      ]);
    }

    if (config.showElectricity) {
      children.addAll([
        const SizedBox(height: _rowGap),
        _label("Electricity"),
        const SizedBox(height: 8),
        _textField(_electricityController, hint: "Enter electricity details"),
      ]);
    }

    return _sectionCard(
      icon: Icons.currency_rupee_outlined,
      title: "Price Details",
      children: children,
    );
  }

  // ===================== FOOTER =====================
  Widget _amenitiesFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Amenities",
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w600,color: Colors.black)),
        GestureDetector(
            onTap: () {
            final config = _fieldConfig;
            // Push latest values into draft
            // Determine monthlyRent to save into draft:
            // - Prefer explicit monthly rent field when present
            // - If listing is Rent but monthly rent field is empty, fall back to Expected Price
            //   so price is not lost for property types where monthly rent UI is hidden.
            String rentVal = _monthlyRentController.text.trim();
            if (rentVal.isEmpty && widget.draft.transactionType.toLowerCase() == 'rent') {
              rentVal = _expectedPriceController.text.trim();
            }

            // Validate area rules before proceeding to next step
            final areaValid = _validateAreaValues(hardValidation: true);
            if (!areaValid) {
              setState(() {}); // refresh UI highlighting
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _areaErrorMessage ??
                        'Please enter valid area values (Carpet ≤ Built-up ≤ Super)',
                  ),
                ),
              );
              return;
            }

            // Validation: if total floors is provided, ensure floor number is not greater than total floors.
            final int enteredFloor = int.tryParse(_floorNumberController.text.trim()) ?? 0;
            final int enteredTotal = int.tryParse(_totalFloorsController.text.trim()) ?? 0;
            if (config.showFloorNumber && config.showTotalFloors && enteredFloor > 0 && enteredTotal > 0 && enteredFloor > enteredTotal) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Floor number cannot be greater than total floors')),
              );
              return;
            }

            widget.draft
              ..bedrooms = config.showBedrooms ? _bedrooms : 0
              ..bathrooms = config.showBathrooms ? _bathrooms : 0
              ..balconies = config.showBalconies ? _balconies : 0
              ..furnishing = config.showFurnishing ? _furnishing : ''
              ..floorNumber = config.showFloorNumber ? (int.tryParse(_floorNumberController.text) ?? 0) : 0
              ..totalFloors = config.showTotalFloors ? (int.tryParse(_totalFloorsController.text) ?? 0) : 0
              ..floorsAllowed = config.showFloorsAllowed ? (int.tryParse(_floorsAllowedController.text) ?? 0) : 0
              ..openSides = config.showOpenSides ? (int.tryParse(_openSidesController.text) ?? 0) : 0
              ..facing = config.showFacing ? _selectedFacing : ''
              ..storeRoom = config.showStoreRoom ? _storeRoom : false
              ..servantRoom = config.showServantRoom ? _servantRoom : false
              ..buildingName = config.showBuildingName ? _buildingNameController.text.trim() : ''
              ..unitNumber = config.showUnitNumber ? _unitNumberController.text.trim() : ''
              ..boundaryWallMade = config.showBoundaryWallMade ? _boundaryWallMade : false
              ..occupancy = config.showOccupancy ? _occupancy : ''
              ..attachedBathroom = config.showAttachedBathroom ? _attachedBathroom : false
              ..electricity = config.showElectricity ? _electricityController.text.trim() : ''
              ..anyConstructionDone = config.showAnyConstructionDone ? _anyConstructionDone : false
              ..monthlyRent = rentVal
              ..expectedPrice = _expectedPriceController.text.trim()
              ..sharedOfficeSpace = config.showSharedOfficeSpace ? _sharedOfficeSpace : false
              ..personalWashroom = config.showPersonalWashroom ? _personalWashroom : false
              ..pantry = config.showPantry ? _pantry : false
              ..howOldIsPG = config.showHowOldIsPG ? _howOldIsPG : ''
              ..attachedBalcony = config.showAttachedBalcony ? _attachedBalcony : false
              ..securityAmount = config.showSecurityAmount ? _securityAmountController.text.trim() : ''
              ..commonArea = config.showCommonArea ? _commonArea : false
              ..tenantsYouPrefer = config.showTenantsYouPrefer ? _tenantsYouPrefer : ''
              ..laundry = config.showLaundry ? _laundryController.text.trim() : ''
              ..areaSqft = int.tryParse(_superAreaController.text) ?? 0
              ..address = _addressController.text.trim()
              ..locality = _localityController.text.trim()
              ..city = _selectedCity ?? widget.draft.city
              // New: push meta fields so DB me null na jaye
              ..possessionStatus = config.showPossessionStatus ? _possessionStatus : ''
              ..availableFrom = config.showAvailableFrom ? _availableFrom : ''
              ..ageOfConstruction = config.showAgeOfConstruction ? _ageOfConstruction : ''
              ..carParking = config.showCarParking ? _carParking : false
              ..lift = config.showLift ? _lift : false
              ..typeOfOwnership = config.showOwnershipType ? _ownershipType : '';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddPostStep3Screen(
                  draft: widget.draft,
                  onBackPressed: () => Navigator.pop(context),
                ),
              ),
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: _primary, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_ios, color: Colors.black),
          ),
        )
      ],
    );
  }

  // ===================== HELPERS =====================
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardbg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: _primary, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700,color: Colors.black)),
          ]),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600));
  }

  // ★ UNIVERSAL TEXT FIELD (Correct UI)
  Widget _textField(
      TextEditingController controller, {
        String? hint,
        TextInputType keyboardType = TextInputType.text,
        Function(String)? onChanged,
        List<TextInputFormatter>? inputFormatters,
        bool isError = false,
        String? suffixText,
      }) {
    final borderColor = isError ? Colors.red : Colors.grey.shade300;
    final focusedBorderColor = isError ? Colors.red : _primary;

    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint ?? "",
          hintStyle:
          GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
          suffixText: suffixText,
          suffixStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: focusedBorderColor, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
      String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey[500])),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.black87)),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _mapBox() {
    // Always show Google Map preview (no buttons). If we don't have a position yet,
    // center on India as a sensible default. Tapping the map opens external maps.
    const LatLng _defaultCenter = LatLng(20.5937, 78.9629);
    final LatLng initial = _mapPosition ?? _defaultCenter;

    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Builder(builder: (_) {
          // If we have precise coordinates, show interactive GoogleMap.
          if (_mapPosition != null) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(target: _mapPosition!, zoom: 15),
              markers: {Marker(markerId: const MarkerId('prop'), position: _mapPosition!)},
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) => _mapController = controller,
              onTap: (_) => _openMapsApp(),
            );
          }

          // If we don't have coords, but address/locality/city exist, show Static Maps image as fallback.
          final addrParts = <String>[];
          if (_addressController.text.trim().isNotEmpty) addrParts.add(_addressController.text.trim());
          if (_localityController.text.trim().isNotEmpty) addrParts.add(_localityController.text.trim());
          if ((_selectedCity ?? widget.draft.city).isNotEmpty) addrParts.add(_selectedCity ?? widget.draft.city);
          if (addrParts.isNotEmpty) {
            final query = Uri.encodeComponent(addrParts.join(', '));
            final apiKey = 'AIzaSyCRdp9XgSwmQ3zVkTyg4kxAYXompT81GqU';
            final staticUrl = 'https://maps.googleapis.com/maps/api/staticmap?center=$query&zoom=15&size=600x300&markers=color:red%7C$query&key=$apiKey';

            return GestureDetector(
              onTap: _openMapsApp,
              child: Container(
                color: Colors.grey.shade200,
                child: Image.network(
                  staticUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (c, e, s) => Center(
                    child: Text('Map preview unavailable', style: TextStyle(color: Colors.grey[600])),
                  ),
                ),
              ),
            );
          }

          // Last resort: show placeholder
          return Container(
            color: Colors.grey.shade200,
            child: const Center(child: Icon(Icons.map, size: 36, color: Colors.grey)),
          );
        }),
      ),
    );
  }

  Future<void> _loadMapForAddress() async {
    final address = _addressController.text.trim();
    final locality = _localityController.text.trim();
    final city = _selectedCity ?? widget.draft.city;

    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (locality.isNotEmpty) parts.add(locality);
    if (city.isNotEmpty) parts.add(city);

    if (parts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter address, locality or city')),
      );
      return;
    }

    final query = parts.join(', ');
    setState(() => _mapLoading = true);

    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          _mapPosition = LatLng(loc.latitude, loc.longitude);
        });
        // animate camera if map already created
        if (_mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_mapPosition!, 15));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to find location')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geocoding failed: $e')),
      );
    } finally {
      setState(() => _mapLoading = false);
    }
  }

  Future<void> _openMapsApp() async {
    final address = _addressController.text.trim();
    final locality = _localityController.text.trim();
    final city = _selectedCity ?? widget.draft.city;

    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (locality.isNotEmpty) parts.add(locality);
    if (city.isNotEmpty) parts.add(city);

    if (parts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter address, locality or city')),
      );
      return;
    }

    final query = parts.join(', ');
    final encoded = Uri.encodeComponent(query);

    final Uri googleIos = Uri.parse('comgooglemaps://?q=$encoded');
    final Uri appleMaps = Uri.parse('https://maps.apple.com/?q=$encoded');
    final Uri geoAndroid = Uri.parse('geo:0,0?q=$encoded');
    final Uri googleWeb =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(googleIos)) {
          await launchUrl(googleIos);
          return;
        }
        if (await canLaunchUrl(appleMaps)) {
          await launchUrl(appleMaps);
          return;
        }
        await launchUrl(googleWeb);
      } else {
        // Android: prefer geo intent, fallback to Google web URL
        if (await canLaunchUrl(geoAndroid)) {
          await launchUrl(geoAndroid);
          return;
        }
        if (await canLaunchUrl(googleWeb)) {
          await launchUrl(googleWeb);
        }
      }
    } catch (e) {
      // Fallback to web Google Maps in case of any error
      if (await canLaunchUrl(googleWeb)) {
        await launchUrl(googleWeb);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  Future<void> _detectMyLocation() async {
    setState(() => _mapLoading = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      final lat = pos.latitude;
      final lng = pos.longitude;

      // Reverse geocode to get address components
      String formattedAddress = '';
      String detectedCity = '';
      String detectedLocality = '';
      String detectedAdmin = '';
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          // Build formattedAddress from available fields
          formattedAddress = [
            p.name,
            p.street,
            p.subLocality,
            p.locality,
            p.subAdministrativeArea,
            p.administrativeArea,
            p.postalCode,
            p.country
          ].where((s) => s != null && s!.isNotEmpty).join(', ');

          // Try multiple placemark fields for city/locality/admin
          detectedCity = p.locality ??
              p.subAdministrativeArea ??
              p.administrativeArea ??
              p.subLocality ??
              '';
          detectedLocality = p.subLocality ?? p.subAdministrativeArea ?? p.locality ?? '';
          detectedAdmin = p.administrativeArea ?? p.subAdministrativeArea ?? '';

          // Debug: print placemark fields to logs
          // ignore: avoid_print
          print('📍 Placemark: name=${p.name}, street=${p.street}, subLocality=${p.subLocality}, locality=${p.locality}, subAdmin=${p.subAdministrativeArea}, admin=${p.administrativeArea}, postal=${p.postalCode}, country=${p.country}');
        }
      } catch (e) {
        // ignore reverse geocode errors but log for debugging
        // ignore: avoid_print
        print('⚠️ placemarkFromCoordinates failed: $e');
      }

      setState(() {
        _mapPosition = LatLng(lat, lng);
        if (detectedCity.isNotEmpty) {
          // Try to match detected city to one of our known states -> cities map.
          // If found, set the state and use the canonical city name from the list.
          String matchedState = '';
          String matchedCity = detectedCity;
          _citiesByState.forEach((state, cities) {
            final found = cities.firstWhere(
                (c) => c.toLowerCase() == detectedCity.toLowerCase(),
                orElse: () => '');
            if (found.isNotEmpty && matchedState.isEmpty) {
              matchedState = state;
              matchedCity = found;
            }
          });
          if (matchedState.isNotEmpty) {
            _selectedState = matchedState;
            _selectedCity = matchedCity;
          } else {
            // City not in our list — set selectedCity to detectedCity,
            // and try to set state from detectedAdmin (administrative area).
            _selectedCity = detectedCity;
            if (detectedAdmin.isNotEmpty) {
              final matchState = _states.firstWhere(
                  (s) => s.toLowerCase() == detectedAdmin.toLowerCase(),
                  orElse: () => '');
              if (matchState.isNotEmpty) {
                _selectedState = matchState;
              } else {
                // try partial match
                final partial = _states.firstWhere(
                    (s) => s.toLowerCase().contains(detectedAdmin.toLowerCase()) || detectedAdmin.toLowerCase().contains(s.toLowerCase()),
                    orElse: () => '');
                if (partial.isNotEmpty) _selectedState = partial;
              }
            }
          }
        }
        else {
          // If detectedCity empty, try to extract city from formattedAddress tokens
          String matchedState = '';
          String matchedCity = '';
          if (formattedAddress.isNotEmpty) {
            final tokens = formattedAddress.split(',').map((s) => s.trim()).toList();
            // iterate tokens from right-to-left to find likely city
            for (var i = tokens.length - 1; i >= 0; i--) {
              final token = tokens[i];
              if (token.length < 2) continue;
              bool foundAny = false;
              _citiesByState.forEach((state, cities) {
                for (var c in cities) {
                  final lc = c.toLowerCase();
                  final tk = token.toLowerCase();
                  if (lc == tk || lc.contains(tk) || tk.contains(lc) || lc.startsWith(tk) || tk.startsWith(lc)) {
                    if (matchedState.isEmpty) {
                      matchedState = state;
                      matchedCity = c;
                      foundAny = true;
                      break;
                    }
                  }
                }
                if (foundAny) return;
              });
              if (matchedState.isNotEmpty) break;
            }
          }
          if (matchedState.isNotEmpty) {
            _selectedState = matchedState;
            _selectedCity = matchedCity;
            // debug
            // ignore: avoid_print
            print('🔎 Matched from address: state=$matchedState city=$matchedCity');
          } else {
            // last-resort: if formattedAddress contains a token, set city to that token
            if (formattedAddress.isNotEmpty) {
              final tokens = formattedAddress.split(',').map((s) => s.trim()).toList();
              if (tokens.isNotEmpty) _selectedCity = tokens.first;
            }
          }
        }
        if (detectedLocality.isNotEmpty) _localityController.text = detectedLocality;
        if (formattedAddress.isNotEmpty) _addressController.text = formattedAddress;
        // animate camera if map controller exists
        if (_mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_mapPosition!, 15));
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not detect location: $e')));
    } finally {
      setState(() => _mapLoading = false);
    }
  }

  Widget _chip(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border:
          Border.all(color: active ? _primary : Colors.grey.shade300),
        ),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.black : Colors.black87)),
      ),
    );
  }

  Widget _directionChip(String label) {
    final selected = _selectedFacing == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFacing = label),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border:
          Border.all(color: selected ? _primary : Colors.grey.shade300),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.black : Colors.black87)),
      ),
    );
  }

  Widget _yesNo(bool yes, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(child: _toggle("Yes", yes, () => onChanged(true))),
        const SizedBox(width: 12),
        Expanded(child: _toggle("No", !yes, () => onChanged(false))),
      ],
    );
  }

  Widget _toggle(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: active ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border:
          Border.all(color: active ? _primary : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.black : Colors.black87)),
        ),
      ),
    );
  }
}
