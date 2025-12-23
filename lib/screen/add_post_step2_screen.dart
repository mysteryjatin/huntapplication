// add_post_step2_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/add_post_step3_screen.dart';
import 'package:hunt_property/models/property_models.dart';
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

  // Indian states and major cities (can be extended from backend later)
  final List<String> _states = const [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
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
    'Uttar Pradesh': ['Lucknow', 'Noida', 'Ghaziabad', 'Kanpur', 'Varanasi'],
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

  int _bedrooms = 4;
  int _bathrooms = 3;
  int _balconies = 3;

  String _furnishing = "Furnished";

  final _floorNumberController = TextEditingController();
  final _totalFloorsController = TextEditingController();
  final _floorsAllowedController = TextEditingController();
  final _openSidesController = TextEditingController(); // ★ Open Sides text-field

  String _selectedFacing = "East";

  bool _storeRoom = true;
  bool _servantRoom = true;

  final _superAreaController = TextEditingController();
  final _builtUpAreaController = TextEditingController();
  final _carpetAreaController = TextEditingController();

  String _transactionType = "New Property";
  String _possessionStatus = "Under Construction";
  String _availableFrom = "After 1 Month";
  String _ageOfConstruction = "New Construction";

  bool _carParking = true;
  bool _lift = true;

  String _ownershipType = "Freehold";

  final _expectedPriceController = TextEditingController();
  final _bookingAmountController = TextEditingController();
  final _maintenanceChargesController = TextEditingController();
  final _brokerageController = TextEditingController(text: "0");

  static const double _outerPadding = 16;
  static const double _cardPadding = 18;
  static const double _rowGap = 16;

  @override
  void dispose() {
    _localityController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
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
    super.dispose();
  }

  // ------------------------------ MAIN UI ------------------------------
  @override
  Widget build(BuildContext context) {
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
          _states,
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
              ? (_citiesByState[_selectedState] ?? [])
              : <String>[],
          (v) => setState(() => _selectedCity = v),
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
    return _sectionCard(
      icon: Icons.home_filled,
      title: "Property Features",
      children: [
        _label("Bedrooms"),
        const SizedBox(height: 8),
        _numberSelectorWithCustom(selected: _bedrooms, onSelect: (v) => setState(() => _bedrooms = v)),
        const SizedBox(height: 20),

        _label("Bathrooms"),
        const SizedBox(height: 8),
        _numberSelectorWithCustom(selected: _bathrooms, onSelect: (v) => setState(() => _bathrooms = v)),
        const SizedBox(height: 20),

        _label("Balconies"),
        const SizedBox(height: 8),
        _numberSelectorWithCustom(selected: _balconies, onSelect: (v) => setState(() => _balconies = v)),
        const SizedBox(height: 20),

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

        _label("Floor Number"),
        const SizedBox(height: 8),
        _textField(_floorNumberController, hint: "Eg. 12"),
        const SizedBox(height: 20),

        Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("Total Floors"),
                const SizedBox(height: 8),
                _textField(_totalFloorsController, hint: "Eg. 20"),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("Floors Allowed"),
                const SizedBox(height: 8),
                _textField(_floorsAllowedController, hint: "Eg. 15"),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        _label("Open Sides"),
        const SizedBox(height: 8),
        _textField(_openSidesController, hint: "Eg. 2"), // ★ As requested
        const SizedBox(height: 20),

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

        _label("Store Room"),
        const SizedBox(height: 8),
        _yesNo(_storeRoom, (v) => setState(() => _storeRoom = v)),
        const SizedBox(height: 20),

        _label("Servant Room"),
        const SizedBox(height: 8),
        _yesNo(_servantRoom, (v) => setState(() => _servantRoom = v)),
      ],
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
    return _sectionCard(
      icon: Icons.square_foot,
      title: "Area",
      children: [
        _label("Super Area (Sq. Ft)"),
        const SizedBox(height: 8),
        _textField(_superAreaController, hint: "Enter area"),
        const SizedBox(height: _rowGap),

        _label("Built Up Area (Sq. Ft)"),
        const SizedBox(height: 8),
        _textField(_builtUpAreaController, hint: "Enter area"),
        const SizedBox(height: _rowGap),

        _label("Carpet Area (Sq. Ft)"),
        const SizedBox(height: 8),
        _textField(_carpetAreaController, hint: "Enter area"),
      ],
    );
  }

  // ===================== TRANSACTION SECTION =====================
  Widget _transactionSection() {
    return _sectionCard(
      icon: Icons.swap_horiz_outlined,
      title: "Transaction Type",
      children: [
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

        _label("Available From"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
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

        _label("Car Parking"),
        const SizedBox(height: 8),
        _yesNo(_carParking, (v) => setState(() => _carParking = v)),
        const SizedBox(height: _rowGap),

        _label("Lift"),
        const SizedBox(height: 8),
        _yesNo(_lift, (v) => setState(() => _lift = v)),
        const SizedBox(height: _rowGap),

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
      ],
    );
  }

  // ===================== PRICE SECTION =====================
  Widget _priceSection() {
    return _sectionCard(
      icon: Icons.currency_rupee_outlined,
      title: "Price Details",
      children: [
        _label("Expected Price"),
        const SizedBox(height: 8),
        _textField(_expectedPriceController, hint: "Enter expected price"),
        const SizedBox(height: _rowGap),

        _label("Booking Amount"),
        const SizedBox(height: 8),
        _textField(_bookingAmountController, hint: "Enter booking amount"),
        const SizedBox(height: _rowGap),

        _label("Maintenance Charges"),
        const SizedBox(height: 8),
        _textField(_maintenanceChargesController, hint: "Enter maintenance charges"),
        const SizedBox(height: _rowGap),

        _label("Brokerage"),
        const SizedBox(height: 8),
        _textField(_brokerageController, hint: "Enter brokerage"),
      ],
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
            // Push latest values into draft
            widget.draft
              ..bedrooms = _bedrooms
              ..bathrooms = _bathrooms
              ..balconies = _balconies
              ..furnishing = _furnishing
              ..floorNumber = int.tryParse(_floorNumberController.text) ?? 0
              ..totalFloors = int.tryParse(_totalFloorsController.text) ?? 0
              ..floorsAllowed = int.tryParse(_floorsAllowedController.text) ?? 0
              ..openSides = int.tryParse(_openSidesController.text) ?? 0
              ..facing = _selectedFacing
              ..storeRoom = _storeRoom
              ..servantRoom = _servantRoom
              ..areaSqft = int.tryParse(_superAreaController.text) ?? 0
              ..address = _addressController.text.trim()
              ..locality = _localityController.text.trim()
              ..city = _selectedCity ?? widget.draft.city;

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
      }) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint ?? "",
          hintStyle:
          GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primary, width: 1.4),
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
    return Container(
      height: 140,
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)),
      child: const Center(
          child: Icon(Icons.map, size: 36, color: Colors.grey)),
    );
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
