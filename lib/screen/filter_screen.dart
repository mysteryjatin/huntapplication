import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/filter_cubit.dart';
import 'package:hunt_property/models/filter_models.dart';

class FilterScreen extends StatefulWidget {
  final ScrollController? scrollController;
  /// Last applied filter — when reopening filter sheet, this state is restored
  final FilterSelection? initialSelection;
  const FilterScreen({super.key, this.scrollController, this.initialSelection});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // ---------------- STATE ----------------
  String _selectedCategory = 'BUY';

  // Full range by default so no budget/area filter applied until user moves sliders
  RangeValues _budgetRange = const RangeValues(0, 1000);
  RangeValues _areaRange = const RangeValues(0, 4000);

  // allow multi-select for bedrooms
  final Set<String> _selectedBedrooms = {};
  Set<int> _selectedYears = {};
  String? _selectedMonth;
  int? _selectedYear;
  String? _selectedPossessionStatus;

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
  // Furnishing now supports multi‑select
  final Set<String> _selectedFurnishings = {};

  static const Color kGreen = Color(0xFF2FED9A);
  static const Color kBorderGrey = Color(0xFFD1D1D1);
  // Static caps
  // BUY: allow budget slider up to 10 Cr (1000 Lacs)
  static const int BUY_CAP_LACS = 1000;
  // RENT: allow monthly rent slider up to 10 Lacs
  static const int RENT_CAP_LACS = 10;
  static const int AREA_CAP_SQFT = 4000;

  int _prettyScore(String s) {
    final hasUpper = RegExp(r'[A-Z]').hasMatch(s);
    final hasLower = RegExp(r'[a-z]').hasMatch(s);
    if (hasUpper && hasLower) return 3; // "Villa", "Semi-furnished"
    if (hasLower) return 2; // "residential"
    if (hasUpper) return 1; // "VILLA"
    return 0;
  }

  List<String> _dedupePrettyStrings(List<String> input) {
    final out = <String>[];
    final indexByKey = <String, int>{};
    final scoreByKey = <String, int>{};

    for (final raw in input) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      final score = _prettyScore(trimmed);

      final existingIndex = indexByKey[key];
      if (existingIndex == null) {
        indexByKey[key] = out.length;
        scoreByKey[key] = score;
        out.add(trimmed);
        continue;
      }

      final bestScore = scoreByKey[key] ?? -1;
      if (score > bestScore) {
        out[existingIndex] = trimmed;
        scoreByKey[key] = score;
      }
    }

    return out;
  }

  List<FilterLocality> _dedupePrettyLocalities(List<FilterLocality> input) {
    final out = <FilterLocality>[];
    final indexByKey = <String, int>{};
    final scoreByKey = <String, int>{};

    for (final loc in input) {
      final v = loc.value.trim();
      final c = loc.city.trim();
      if (v.isEmpty && c.isEmpty) continue;
      final key = '${c.toLowerCase()}|${v.toLowerCase()}';
      final score = _prettyScore(c) * 10 + _prettyScore(v);

      final existingIndex = indexByKey[key];
      if (existingIndex == null) {
        indexByKey[key] = out.length;
        scoreByKey[key] = score;
        out.add(FilterLocality(value: v, city: c));
        continue;
      }

      final bestScore = scoreByKey[key] ?? -1;
      if (score > bestScore) {
        out[existingIndex] = FilterLocality(value: v, city: c);
        scoreByKey[key] = score;
      }
    }

    return out;
  }

  @override
  void initState() {
    super.initState();
    final init = widget.initialSelection;
    if (init != null) {
      _selectedCategory = init.category;
    }
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
            _transactionTypes = _dedupePrettyStrings(data.transactionTypes);
            _propertyCategories = _dedupePrettyStrings(data.propertyCategories);
            _propertySubtypes = _dedupePrettyStrings(data.propertySubtypes);
            _furnishingOptions = _dedupePrettyStrings(data.furnishingOptions);
            _facingOptions = _dedupePrettyStrings(data.facingOptions);
            _cities = _dedupePrettyStrings(data.cities);
            _localities = _dedupePrettyLocalities(data.localities);

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

            // Default budget slider to full available range so that
            // by default no price filter is applied.
            _budgetRange = RangeValues(lMin, lMax);

            // Use static area cap
            _areaMin = 0;
            _areaMax = AREA_CAP_SQFT;
            // Default area slider to full available range so that
            // by default no area filter is applied.
            _areaRange =
                RangeValues(_areaMin.toDouble(), _areaMax.toDouble());

            _bedroomsOptions = data.bedrooms.where((b) => b > 0).toList();
            if (_bedroomsOptions.isEmpty) _bedroomsOptions = [1, 2, 3, 4];
            _bathroomsOptions = data.bathrooms.isNotEmpty ? data.bathrooms : [1, 2];
            _possessionStatusOptions = data.possessionStatusOptions;
            _availabilityMonths = data.availabilityMonths;
            _availabilityYears = data.availabilityYears;
            _ageOfConstructionOptions = data.ageOfConstructionOptions;

            // Restore last applied filter when reopening sheet
            final init = widget.initialSelection;
            if (init != null) {
              if (init.budgetMin != null && init.budgetMax != null) {
                final lMinVal = (init.budgetMin! / 100000).toDouble().clamp(lMin, lMax);
                final lMaxVal = (init.budgetMax! / 100000).toDouble().clamp(lMin, lMax);
                _budgetRange = RangeValues(lMinVal, lMaxVal);
              }
              if (init.areaMin != null && init.areaMax != null) {
                final aMin = init.areaMin!.toDouble().clamp(_areaMin.toDouble(), _areaMax.toDouble());
                final aMax = init.areaMax!.toDouble().clamp(_areaMin.toDouble(), _areaMax.toDouble());
                _areaRange = RangeValues(aMin, aMax);
              }
              if (init.bedroomsList != null && init.bedroomsList!.isNotEmpty) {
                _selectedBedrooms.clear();
                for (final b in init.bedroomsList!) {
                  if (b > 0) _selectedBedrooms.add('$b BHK');
                }
              } else if (init.bedrooms != null && init.bedrooms! > 0) {
                _selectedBedrooms.clear();
                _selectedBedrooms.add('${init.bedrooms} BHK');
              }
              if (init.furnishing != null && init.furnishing!.isNotEmpty) {
                final f = init.furnishing!.trim().toLowerCase().replaceAll(' ', '-');
                for (final opt in _furnishingOptions) {
                  if (opt.trim().toLowerCase().replaceAll(' ', '-') == f) {
                    _selectedFurnishings
                      ..clear()
                      ..add(opt);
                    break;
                  }
                }
              }
              if (init.possessionStatus != null && init.possessionStatus!.isNotEmpty) {
                final v = init.possessionStatus!.trim().toLowerCase();
                for (final m in _possessionStatusOptions) {
                  if ((m['value'] ?? '').toString().toLowerCase() == v) {
                    _selectedPossessionStatus = m['label'] ?? init.possessionStatus;
                    break;
                  }
                }
                if (_selectedPossessionStatus == null) _selectedPossessionStatus = init.possessionStatus;
              }
              if (init.availabilityMonth != null && init.availabilityMonth!.isNotEmpty) {
                final raw = init.availabilityMonth!.trim();
                final monthInt = int.tryParse(raw);
                if (monthInt != null && monthInt >= 1 && monthInt <= 12) {
                  for (final m in _availabilityMonths) {
                    if (m['value'] == monthInt || m['value'].toString() == raw) {
                      _selectedMonth = (m['label'] ?? '').toString();
                      break;
                    }
                  }
                }
                if (_selectedMonth == null) _selectedMonth = init.availabilityMonth;
              }
              if (init.availabilityYear != null && init.availabilityYear!.isNotEmpty) {
                _selectedYear = int.tryParse(init.availabilityYear!.trim());
              }
              if (init.ageOfConstruction != null &&
                  init.ageOfConstruction!.isNotEmpty) {
                // init.ageOfConstruction holds backend *values* (e.g. "new_construction")
                // but UI stores/compares user-facing labels in _selectedConstruction.
                _selectedConstruction.clear();
                for (final v in init.ageOfConstruction!) {
                  for (final m in _ageOfConstructionOptions) {
                    if ((m['value'] ?? '').toString() == v) {
                      final label = (m['label'] ?? '').toString();
                      if (label.isNotEmpty) {
                        _selectedConstruction.add(label);
                      }
                    }
                  }
                }
              }
            }
          });
        }
      },
      child: Container(
        width: double.infinity,
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
            // set sensible defaults immediately for BUY: 0 - BUY_CAP_LACS Lacs (e.g. up to 10 Cr)
            _priceMin = 0;
            _priceMax = (_priceMax < BUY_CAP_LACS * 100000)
                ? _priceMax
                : BUY_CAP_LACS * 100000;
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
            // set sensible defaults immediately for RENT: 0 - RENT_CAP_LACS Lacs (e.g. up to 10 Lacs)
            _priceMin = 0;
            _priceMax = (_priceMax < RENT_CAP_LACS * 100000)
                ? _priceMax
                : RENT_CAP_LACS * 100000;
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
    // Determine current cap based on category so we can show "10 L+" / "10 Cr+"
    final isBuy = _selectedCategory == 'BUY';
    final capLacs = (isBuy ? BUY_CAP_LACS : RENT_CAP_LACS).toDouble();
    final isMax = lacs >= capLacs;

    // Convert lacs -> rupees so we can format as ₹1K, ₹1 L, ₹1 Cr etc.
    final rupees = lacs * 100000.0;

    String base;

    if (rupees == 0) {
      base = '₹ 0';
    }
    // < 1 Lac => show in thousands (₹ 1K, ₹ 2K, ... ₹ 95K)
    else if (rupees < 100000) {
      final thousands = rupees / 1000.0;
      final display = thousands.truncateToDouble() == thousands
          ? thousands.toStringAsFixed(0)
          : thousands.toStringAsFixed(1);
      base = '₹ ${display}K';
    }
    // 1 Lac to < 1 Cr => show in L (₹ 1 L, ₹ 1.1 L, ...)
    else if (rupees < 10000000) {
      final l = rupees / 100000.0;
      final display = l.truncateToDouble() == l
          ? l.toStringAsFixed(0)
          : l.toStringAsFixed(1);
      base = '₹ $display L';
    }
    // >= 1 Cr => show in Cr (₹ 1 Cr, ₹ 1.5 Cr, ...)
    else {
      final cr = rupees / 10000000.0;
      final display = cr.truncateToDouble() == cr
          ? cr.toStringAsFixed(0)
          : cr.toStringAsFixed(1);
      base = '₹ $display Cr';
    }

    return isMax ? '$base+' : base;
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
        final selected = _selectedFurnishings.contains(f);
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              _selectedFurnishings.remove(f);
            } else {
              _selectedFurnishings.add(f);
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? kGreen : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: selected ? kGreen : kBorderGrey),
            ),
            child: Text(
              f,
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
    // Single-select chips styled like design: pill buttons in a wrap
    const options = [
      "Immediately",
      "After 1 Month",
      "After 3 Month",
      "After 7 Month",
      "After 9 Month",
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((label) {
        final selected = _selectedMonth == label;
        return GestureDetector(
          onTap: () => setState(() => _selectedMonth = label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? kGreen : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: selected ? kGreen : kBorderGrey),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.black : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Two cards per row with `spacing: 10` in the Wrap.
        final itemWidth = ((w - 10) / 2).clamp(0.0, double.infinity);

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
      },
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

                  // Decide whether budget/area sliders are effectively "no filter" (full range)
                  final sliderBudgetMinLacs =
                      (_priceMin / 100000).toDouble();
                  final sliderBudgetMaxLacs =
                      (_priceMax / 100000).toDouble();
                  const epsilon = 0.01;

                  final isFullBudgetRange =
                      (_budgetRange.start - sliderBudgetMinLacs).abs() <=
                          epsilon &&
                          (_budgetRange.end - sliderBudgetMaxLacs).abs() <=
                              epsilon;

                  final sliderAreaMin = _areaMin.toDouble();
                  final sliderAreaMax = _areaMax.toDouble();
                  final isFullAreaRange =
                      (_areaRange.start - sliderAreaMin).abs() <= epsilon &&
                          (_areaRange.end - sliderAreaMax).abs() <= epsilon;

                  final num? budgetMin =
                      isFullBudgetRange ? null : _budgetRange.start * 100000;
                  final num? budgetMax =
                      isFullBudgetRange ? null : _budgetRange.end * 100000;
                  final num? areaMin =
                      isFullAreaRange ? null : _areaRange.start;
                  final num? areaMax =
                      isFullAreaRange ? null : _areaRange.end;

                  // Map selected possession label -> backend value
                  String? possessionValue;
                  if (_selectedPossessionStatus != null &&
                      _selectedPossessionStatus!.isNotEmpty) {
                    for (final m in _possessionStatusOptions) {
                      final label = m['label'] ?? '';
                      if (label == _selectedPossessionStatus) {
                        final v = m['value'] ?? '';
                        if (v.isNotEmpty) possessionValue = v;
                        break;
                      }
                    }
                    // Fallback: if no explicit value found, still send label
                    possessionValue ??= _selectedPossessionStatus;
                  }

                  // Map selected availability month label -> backend value
                  String? availabilityMonthValue;
                  if (_selectedMonth != null && _selectedMonth!.isNotEmpty) {
                    if (_availabilityMonths.isNotEmpty) {
                      for (final m in _availabilityMonths) {
                        final label = (m['label'] ?? '').toString();
                        if (label == _selectedMonth) {
                          final raw = m['value'];
                          if (raw != null) {
                            availabilityMonthValue = raw.toString();
                          }
                          break;
                        }
                      }
                    }
                    // Fallback: if backend didn't provide mapping or we didn't find it,
                    // keep using the label so month-name converter on service side can handle it.
                    availabilityMonthValue ??= _selectedMonth;
                  }

                  // Map selected age-of-construction labels -> backend values
                  List<String>? ageForSearch;
                  if (_selectedConstruction.isNotEmpty) {
                    final values = <String>[];
                    for (final label in _selectedConstruction) {
                      for (final m in _ageOfConstructionOptions) {
                        final optLabel = (m['label'] ?? '').toString();
                        if (optLabel == label) {
                          final v = (m['value'] ?? '').toString();
                          if (v.isNotEmpty) values.add(v);
                          break;
                        }
                      }
                    }
                    if (values.isNotEmpty) {
                      ageForSearch = values;
                    }
                  }

                  // Furnishing: multi‑select UI, but backend currently supports
                  // a single value. For now, send the first selected option.
                  String? furnishingForSearch;
                  if (_selectedFurnishings.isNotEmpty) {
                    furnishingForSearch = _selectedFurnishings.first;
                  }

                  final selection = FilterSelection(
                    category: _selectedCategory,
                    // Convert Lacs back to rupees for backend queries (only if not full range)
                    budgetMin: budgetMin,
                    budgetMax: budgetMax,
                    areaMin: areaMin,
                    areaMax: areaMax,
                    bedrooms: bedroomCount,
                    bedroomsList: bedroomsList,
                    furnishing: furnishingForSearch,
                    possessionStatus: possessionValue,
                    availabilityMonth: availabilityMonthValue,
                    availabilityYear:
                        _selectedYear != null ? _selectedYear.toString() : null,
                    ageOfConstruction: ageForSearch,
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
      // Full range = no filter applied
      _budgetRange = const RangeValues(0, 1000);
      _areaRange = const RangeValues(0, 4000);
      _selectedBedrooms.clear();
      _selectedYears.clear();
      _selectedMonth = null;
      _selectedYear = null;
      _selectedConstruction.clear();
      _selectedPossessionStatus = null;
      _selectedFurnishings.clear();
    });
    _loadFilters();
  }
}

