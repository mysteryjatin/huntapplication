import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/filter_cubit.dart';
import 'package:hunt_property/models/filter_models.dart';

class FilterScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const FilterScreen({super.key, this.scrollController});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // ---------------- STATE ----------------
  String _selectedCategory = 'BUY';

  RangeValues _budgetRange = const RangeValues(15, 25);
  RangeValues _areaRange = const RangeValues(15, 25);

  // allow multi-select for bedrooms
  final Set<String> _selectedBedrooms = {};
  Set<int> _selectedYears = {};
  String? _selectedMonth;
  int? _selectedYear;
  String _selectedPossessionStatus = "Under Construction";

  // Multi select
  final Set<String> _selectedConstruction = {};

  // --- Options populated from backend ---
  List<String> _transactionTypes = [];
  List<String> _propertyCategories = [];
  List<String> _propertySubtypes = [];
  List<String> _furnishingOptions = [];
  List<String> _facingOptions = [];
  List<String> _cities = [];
  List<FilterLocality> _localities = [];
  num _priceMin = 0;
  num _priceMax = 400000;
  num _areaMin = 0;
  num _areaMax = 4000;
  List<int> _bedroomsOptions = [1, 2, 3, 4];
  List<int> _bathroomsOptions = [1, 2];
  List<Map<String, String>> _possessionStatusOptions = [];
  List<Map<String, dynamic>> _availabilityMonths = [];
  List<int> _availabilityYears = [];
  List<Map<String, String>> _ageOfConstructionOptions = [];
  String? _selectedFurnishing;

  static const Color kGreen = Color(0xFF2FED9A);
  static const Color kBorderGrey = Color(0xFFD1D1D1);
  // Static caps
  static const int BUY_CAP_LACS = 100;
  static const int RENT_CAP_LACS = 10;
  static const int AREA_CAP_SQFT = 4000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFilters();
    });
  }

  String _txnTypeFromCategory(String category) {
    // BUY => sale, RENT => rent
    return category == 'RENT' ? 'rent' : 'sale';
  }

  void _loadFilters() {
    // Response print FilterService me ho raha hai (console/terminal).
    context.read<FilterCubit>().load(
          transactionType: _txnTypeFromCategory(_selectedCategory),
        );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    // UI same rahegi; BlocListener se sirf state log ho jaayega.
    return BlocListener<FilterCubit, FilterState>(
      listener: (context, state) {
        // ignore: avoid_print
        print('🔎 FilterCubit state: $state');
        if (state is FilterLoaded) {
          final data = state.data;
          // price range from API is in rupees — convert to Lacs for UI slider
          final pmin = data.priceRange.min;
          final pmax = data.priceRange.max;
          final areaMin = data.areaRange.min;
          final areaMax = data.areaRange.max;

          setState(() {
            _transactionTypes = data.transactionTypes;
            _propertyCategories = data.propertyCategories;
            _propertySubtypes = data.propertySubtypes;
            _furnishingOptions = data.furnishingOptions;
            _facingOptions = data.facingOptions;
            _cities = data.cities;
            _localities = data.localities;

            // Apply backend values, normalize units (API may return rupees or lacs).
            // Heuristic: if pmax >= 100000 treat incoming values as rupees, else treat as Lacs.
            num pminRupees;
            num pmaxRupees;
            if (pmax >= 100000) {
              // incoming already in rupees
              pminRupees = pmin;
              pmaxRupees = pmax;
            } else {
              // incoming likely in Lacs -> convert to rupees
              pminRupees = pmin * 100000;
              pmaxRupees = pmax * 100000;
            }

            // Ignore backend price_range; use static caps per category
            final cap = (_selectedCategory == 'RENT') ? RENT_CAP_LACS * 100000 : BUY_CAP_LACS * 100000;
            _priceMin = 0;
            _priceMax = cap;

            // convert rupees -> Lacs for slider display
            final lMin = (_priceMin / 100000).toDouble();
            var lMax = (_priceMax / 100000).toDouble();
            // Ensure at least a small positive range to avoid identical min/max
            if (lMax <= lMin) lMax = lMin + 1.0;

            // Ensure sensible defaults and clamp previous selection into new range
            final start = _budgetRange.start.clamp(lMin, lMax);
            final end = _budgetRange.end.clamp(lMin, lMax);
            _budgetRange = RangeValues(start, end);

            // Use static area cap
            _areaMin = 0;
            _areaMax = AREA_CAP_SQFT;
            final aStart = _areaRange.start.clamp(_areaMin.toDouble(), _areaMax.toDouble());
            final aEnd = _areaRange.end.clamp(_areaMin.toDouble(), _areaMax.toDouble());
            _areaRange = RangeValues(aStart, aEnd);

            _bedroomsOptions = data.bedrooms.where((b) => b > 0).toList();
            if (_bedroomsOptions.isEmpty) _bedroomsOptions = [1, 2, 3, 4];
            _bathroomsOptions = data.bathrooms.isNotEmpty ? data.bathrooms : [1, 2];
            _possessionStatusOptions = data.possessionStatusOptions;
            _availabilityMonths = data.availabilityMonths;
            _availabilityYears = data.availabilityYears;
            _ageOfConstructionOptions = data.ageOfConstructionOptions;
          });
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _dragHandle(),
            const Text("Filter",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("Category"),
                    _categoryButtons(),

                    _gap(),
                    _title("Budget"),
                    _budgetUI(),

                    _gap(),
                    _title("Furnishing"),
                    _furnishingSelector(),

                    _gap(),
                    _title("Bedroom"),
                    _bedroomSelector(),

                    _gap(),
                    _title("Availability"),
                    _availabilityRow(),

                    _gap(),
                    _title("Possession Status"),
                    _possessionRow(),

                    _gap(),
                    _title("Age of construction"),
                    _ageConstructionGrid(),

                    _gap(),
                    _title("Area (Sq.ft.)"),
                    _areaSelector(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            _footerButtons(),
          ],
        ),
      ),
    );
  }

  // ---------------- SMALL WIDGETS ----------------

  Widget _dragHandle() => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 12),
        child: Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          t,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      );

  Widget _gap() => const SizedBox(height: 12);

  // ---------------- CATEGORY ----------------

  Widget _categoryButtons() {
    return Row(
      children: [
        _pill("BUY", _selectedCategory == "BUY", () {
          setState(() {
            _selectedCategory = "BUY";
            // set sensible defaults immediately for BUY: 0 - 100 Lacs
            _priceMin = 0;
            _priceMax = (_priceMax < 100 * 100000) ? _priceMax : 100 * 100000;
            final lMin = (_priceMin / 100000).toDouble();
            final lMax = (_priceMax / 100000).toDouble();
            _budgetRange = RangeValues(lMin, lMax);
          });
          _loadFilters();
        }),
        const SizedBox(width: 12),
        _pill("RENT", _selectedCategory == "RENT", () {
          setState(() {
            _selectedCategory = "RENT";
            // set sensible defaults immediately for RENT: 0 - 10 Lacs
            _priceMin = 0;
            _priceMax = (_priceMax < 10 * 100000) ? _priceMax : 10 * 100000;
            final lMin = (_priceMin / 100000).toDouble();
            final lMax = (_priceMax / 100000).toDouble();
            _budgetRange = RangeValues(lMin, lMax);
          });
          _loadFilters();
        }),
      ],
    );
  }

  Widget _pill(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kGreen : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kGreen),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
    );
  }

  // ---------------- BUDGET ----------------

  Widget _budgetUI() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _chip(_formatPriceLabel(_budgetRange.start)),
            _chip(_formatPriceLabel(_budgetRange.end)),
          ],
        ),
        Builder(builder: (_) {
          final minD = (_priceMin / 100000).toDouble();
          final maxD = (_priceMax / 100000).toDouble();
          // Ensure slider values remain within min/max to avoid assertion
          final safeStart = _budgetRange.start.clamp(minD, maxD);
          final safeEnd = _budgetRange.end.clamp(minD, maxD);
          final values = RangeValues(safeStart as double, safeEnd as double);

          return RangeSlider(
            values: values,
            min: minD,
            max: maxD,
            activeColor: kGreen,
            inactiveColor: kBorderGrey,
            onChanged: (v) {
              // keep state within bounds
              final s = v.start.clamp(minD, maxD) as double;
              final e = v.end.clamp(minD, maxD) as double;
              setState(() => _budgetRange = RangeValues(s, e));
            },
          );
        }),
      ],
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );

  String _formatPriceLabel(double lacs) {
    if (lacs >= 100) {
      final cr = lacs / 100.0;
      return '${cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 1)} Cr';
    }
    return '${lacs.toInt()} Lacs';
  }

  // ---------------- BEDROOM ----------------

  Widget _bedroomSelector() {
    // Build display items from backend options, always include 4 BHK and 4+ BHK when appropriate
    final maxBed = _bedroomsOptions.isNotEmpty ? (_bedroomsOptions.reduce((a, b) => a > b ? a : b)) : 4;
    final items = <String>[];
    for (final b in _bedroomsOptions) {
      final label = '${b} BHK';
      if (!items.contains(label)) items.add(label);
    }
    // Ensure 4 BHK present
    if (!items.contains('4 BHK')) items.add('4 BHK');
    // Add "4+ BHK" option when API indicates 4 or more available
    if (maxBed >= 4 && !items.contains('4+ BHK')) items.add('4+ BHK');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((room) {
        final sel = _selectedBedrooms.contains(room);
        return GestureDetector(
          onTap: () => setState(() {
            if (sel) {
              _selectedBedrooms.remove(room);
            } else {
              _selectedBedrooms.add(room);
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? kGreen : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: sel ? kGreen : kBorderGrey),
            ),
            child: Text(
              room,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- FURNISHING ----------------

  Widget _furnishingSelector() {
    if (_furnishingOptions.isEmpty) {
      // show default options if backend didn't provide
      _furnishingOptions = ['Furnished', 'Semi-furnished', 'Unfurnished'];
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _furnishingOptions.map((f) {
        final selected = _selectedFurnishing == f;
        return GestureDetector(
          onTap: () => setState(() => _selectedFurnishing = selected ? null : f),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? kGreen : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: selected ? kGreen : kBorderGrey),
            ),
            child: Text(f, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- AVAILABILITY ----------------

  Widget _availabilityRow() {
    // Use backend-provided availability months/years when available
    final months = _availabilityMonths.isNotEmpty
        ? _availabilityMonths.map((m) => m['label']?.toString() ?? '').where((s) => s.isNotEmpty).toList()
        : <String>["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    final years = _availabilityYears.isNotEmpty
        ? _availabilityYears
        : List<int>.generate(7, (i) => DateTime.now().year + i);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorderGrey)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                isDense: true,
                style: const TextStyle(fontSize: 13, color: Colors.black),
                hint: const Text("Month", style: TextStyle(fontSize: 13)),
                value: _selectedMonth,
                items: months
                    .map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedMonth = v),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorderGrey)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                isDense: true,
                style: const TextStyle(fontSize: 13, color: Colors.black),
                hint: const Text("Year", style: TextStyle(fontSize: 13)),
                value: _selectedYear,
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text("$y", style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedYear = v),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- POSSESSION ----------------

  Widget _possessionRow() {
    // Use backend-provided options when available
    final opts = _possessionStatusOptions.isNotEmpty
        ? _possessionStatusOptions.map((m) => m['label'] ?? '').where((s) => s.isNotEmpty).toList()
        : ["Under Construction", "Ready to move"];

    return Row(
      children: [
        for (var i = 0; i < opts.length; i++) ...[
          Expanded(child: _pill2(opts[i], _selectedPossessionStatus == opts[i])),
          if (i < opts.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _pill2(String text, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPossessionStatus = text),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? kGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? kGreen : kBorderGrey),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black,fontSize: 12),
          ),
        ),
      ),
    );
  }

  // ---------------- AGE OF CONSTRUCTION ----------------

  Widget _ageConstructionGrid() {
    final items = _ageOfConstructionOptions.isNotEmpty
        ? _ageOfConstructionOptions.map((m) => m['label'] ?? '').where((s) => s.isNotEmpty).toList()
        : [
            "New Construction",
            "Less than 5 Years",
            "5 to 10 Years",
            "15 to 20+ Years",
          ];

    final w = MediaQuery.of(context).size.width;
    final itemWidth = (w - 40 - 14) / 2;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((label) {
        final selected = _selectedConstruction.contains(label);

        return GestureDetector(
          onTap: () {
            setState(() {
              selected
                  ? _selectedConstruction.remove(label)
                  : _selectedConstruction.add(label);
            });
          },
          child: Container(
            width: itemWidth,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? kGreen : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGreen, width: 1.6),
              boxShadow: selected
                  ? []
                  : [
                      // subtle elevation for unselected cards to match design
                      BoxShadow(
                        color: Colors.black.withOpacity(.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon on the left
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.apartment,
                      size: 18, color: selected ? Colors.black : kGreen),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.black : Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- AREA (Sq.ft.) ----------------

  Widget _areaSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _chip("${_areaRange.start.toInt()} Sq.ft"),
            _chip("${_areaRange.end.toInt()} Sq.ft"),
          ],
        ),
        const SizedBox(height: 12),
        Builder(builder: (_) {
          final minD = _areaMin.toDouble();
          final maxD = _areaMax.toDouble();
          final diff = maxD - minD;
          final int? divisions = diff >= 1.0 ? 100 : null;
          final safeStart = _areaRange.start.clamp(minD, maxD);
          final safeEnd = _areaRange.end.clamp(minD, maxD);
          return RangeSlider(
            values: RangeValues(safeStart as double, safeEnd as double),
            min: minD,
            max: maxD,
            divisions: divisions,
            activeColor: kGreen,
            inactiveColor: kBorderGrey.withOpacity(.4),
            onChanged: (v) => setState(() => _areaRange = RangeValues(v.start.clamp(minD, maxD) as double, v.end.clamp(minD, maxD) as double)),
          );
        }),
      ],
    );
  }

  // ---------------- FOOTER ----------------

  Widget _footerButtons() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kBorderGrey, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _resetFilters,
                child: const Text("Reset",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // FilterSelection banake SearchScreen ko wapas bhej do
                  int? bedroomCount;
                  List<int>? bedroomsList;
                  if (_selectedBedrooms.isNotEmpty) {
                    bedroomsList = _selectedBedrooms
                        .map((s) {
                          // s could be "3 BHK" or "4+ BHK" - extract leading digits
                          final token = s.split(' ').first;
                          final digits = token.replaceAll(RegExp(r'[^0-9]'), '');
                          return int.tryParse(digits) ?? 0;
                        })
                        .where((v) => v > 0)
                        .toSet()
                        .toList();
                    if (bedroomsList.length == 1) {
                      bedroomCount = bedroomsList.first;
                    }
                  }

                  final selection = FilterSelection(
                    category: _selectedCategory,
                    // Convert Lacs back to rupees for backend queries
                    budgetMin: _budgetRange.start * 100000,
                    budgetMax: _budgetRange.end * 100000,
                    areaMin: _areaRange.start,
                    areaMax: _areaRange.end,
                    bedrooms: bedroomCount,
                    bedroomsList: bedroomsList,
                    furnishing: _selectedFurnishing,
                  );

                  Navigator.of(context).pop(selection);
                },
                child: const Text("Apply",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = "BUY";
      _budgetRange = const RangeValues(15, 25);
      _areaRange = const RangeValues(15, 25);
      _selectedBedrooms.clear();
      _selectedYears.clear();
      _selectedMonth = null;
      _selectedYear = null;
      _selectedConstruction.clear();
      _selectedPossessionStatus = "Under Construction";
    });
    _loadFilters();
  }
}

