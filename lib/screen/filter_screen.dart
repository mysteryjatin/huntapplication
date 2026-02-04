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

  String? _selectedBedroom;
  Set<int> _selectedYears = {};
  String _selectedPossessionStatus = "Under Construction";

  // Multi select
  final Set<String> _selectedConstruction = {};

  static const Color kGreen = Color(0xFF2FED9A);
  static const Color kBorderGrey = Color(0xFFD1D1D1);

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

  Widget _gap() => const SizedBox(height: 20);

  // ---------------- CATEGORY ----------------

  Widget _categoryButtons() {
    return Row(
      children: [
        _pill("BUY", _selectedCategory == "BUY", () {
          setState(() => _selectedCategory = "BUY");
          _loadFilters();
        }),
        const SizedBox(width: 12),
        _pill("RENT", _selectedCategory == "RENT", () {
          setState(() => _selectedCategory = "RENT");
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
            _chip("${_budgetRange.start.toInt()} Lacs"),
            _chip("${_budgetRange.end.toInt()} Lacs"),
          ],
        ),
        RangeSlider(
          values: _budgetRange,
          min: 0,
          max: 100,
          activeColor: kGreen,
          inactiveColor: kBorderGrey,
          onChanged: (v) => setState(() => _budgetRange = v),
        ),
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

  // ---------------- BEDROOM ----------------

  Widget _bedroomSelector() {
    final rooms = ["1 BHK", "2 BHK", "3 BHK", "4 BHK"];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: rooms.map((room) {
        final sel = _selectedBedroom == room;
        return GestureDetector(
          onTap: () => setState(() => _selectedBedroom = sel ? null : room),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: sel ? kGreen : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: sel ? kGreen : kBorderGrey),
            ),
            child: Text(
              room,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- AVAILABILITY ----------------

  Widget _availabilityRow() {
    final years = [2023, 2024, 2025, 2026];

    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: years.map((yr) {
        final sel = _selectedYears.contains(yr);
        return GestureDetector(
          onTap: () {
            setState(() {
              sel ? _selectedYears.remove(yr) : _selectedYears.add(yr);
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: sel ? kGreen : Colors.white,
                  border: Border.all(color: sel ? kGreen : kBorderGrey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: sel
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Text("$yr",
                  style: TextStyle(
                      color: sel ? Colors.black : Colors.black54)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------------- POSSESSION ----------------

  Widget _possessionRow() {
    return Row(
      children: [
        Expanded(
            child: _pill2("Under Construction",
                _selectedPossessionStatus == "Under Construction")),
        const SizedBox(width: 12),
        Expanded(
            child: _pill2(
                "Ready to move", _selectedPossessionStatus == "Ready to move")),
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
                fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
      ),
    );
  }

  // ---------------- AGE OF CONSTRUCTION ----------------

  Widget _ageConstructionGrid() {
    final items = [
      "New Construction",
      "Less than 5 Years",
      "5 to 10 Years",
      "15 to 20+ Years",
    ];

    final w = MediaQuery.of(context).size.width;
    final itemWidth = (w - 40 - 14) / 2;

    return Wrap(
      spacing: 14,
      runSpacing: 14,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? kGreen.withOpacity(.15) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selected ? kGreen : kBorderGrey, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.apartment,
                    size: 18, color: selected ? kGreen : Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? kGreen : Colors.black87),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, size: 16, color: kGreen),
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
        RangeSlider(
          values: _areaRange,
          min: 0,
          max: 100,
          divisions: 100,
          activeColor: kGreen,
          inactiveColor: kBorderGrey.withOpacity(.4),
          onChanged: (v) => setState(() => _areaRange = v),
        ),
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
                  if (_selectedBedroom != null &&
                      _selectedBedroom!.trim().isNotEmpty) {
                    // "1 BHK" => 1, "2 BHK" => 2 ...
                    final first = _selectedBedroom!.trim().split(' ').first;
                    bedroomCount = int.tryParse(first);
                  }

                  final selection = FilterSelection(
                    category: _selectedCategory,
                    budgetMin: _budgetRange.start,
                    budgetMax: _budgetRange.end,
                    areaMin: _areaRange.start,
                    areaMax: _areaRange.end,
                    bedrooms: bedroomCount,
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
      _selectedBedroom = null;
      _selectedYears.clear();
      _selectedConstruction.clear();
      _selectedPossessionStatus = "Under Construction";
    });
    _loadFilters();
  }
}

