// property_cost_calculator_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:hunt_property/theme/app_theme.dart';

class PropertyCostCalculatorScreen extends StatefulWidget {
  const PropertyCostCalculatorScreen({super.key});

  @override
  State<PropertyCostCalculatorScreen> createState() =>
      _PropertyCostCalculatorScreenState();
}

class _PropertyCostCalculatorScreenState
    extends State<PropertyCostCalculatorScreen> {
  // Top form controllers
  final TextEditingController developerCtrl = TextEditingController();
  final TextEditingController projectCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController sizeCtrl = TextEditingController();
  int propertyTypeIndex = 0; // 0 res,1 com,2 others
  int unitIndex = 0; // 0 sqft,1 sqyrd,2 sqm

  // Annexure lists (model)
  late List<AnnexureRow> annexureI;
  late List<AnnexureRow> annexureII;
  late List<AnnexureRow> annexureIII;

  @override
  void initState() {
    super.initState();

    annexureI = [
      'Basic Selling Price (BSP)',
      'Electrification Charges (EFC)',
      'Fire Fighting Charges (FFC)',
      'Interest Free Maintaining Deposit (IFMS)',
      'Floor PLC',
      'View PLC',
      'Other PLC',
      'Lease Rent',
      'Annual Maintenance Charges',
      'Sinking Fund Charges',
    ].map((name) => AnnexureRow(name: name)).toList();

    annexureII = [
      'External Development Charges (EDC)',
      'Internal Development Charges (IDC)',
    ].map((name) => AnnexureRow(name: name)).toList();

    annexureIII = [
      'Car Parking (Open)',
      'Car Parking (Covered)',
      'Club Membership',
      'Water Connection Charges',
      'Gas Connection Charges',
      'Meter Installation Charges (Per KVA)',
      'Golf Course Membership',
      'Electric Substation Charges (ESSC)',
      'Wood work Charges',
      'Home Appliance Charges',
      'Other Charges',
    ].map((name) => AnnexureRow(name: name)).toList();
  }

  @override
  void dispose() {
    developerCtrl.dispose();
    projectCtrl.dispose();
    locationCtrl.dispose();
    sizeCtrl.dispose();
    for (var r in annexureI + annexureII + annexureIII) {
      r.dispose();
    }
    super.dispose();
  }

  // Compute totals
  double get annexureISum =>
      annexureI.fold(0.0, (s, r) => s + (r.price * r.units));
  double get annexureIISum =>
      annexureII.fold(0.0, (s, r) => s + (r.price * r.units));
  double get annexureIIISum =>
      annexureIII.fold(0.0, (s, r) => s + (r.price * r.units));

  double get grandTotal => annexureISum + annexureIISum + annexureIIISum;

  // helpers to format rupee (no intl)
  String formatCurrency(double v) {
    if (v.isNaN || v.isInfinite) return '₹0';
    final rounded = (v * 100).round() / 100.0;
    if ((rounded - rounded.truncateToDouble()).abs() < 0.0001) {
      return '₹${rounded.toInt()}';
    } else {
      return '₹${rounded.toStringAsFixed(2)}';
    }
  }

  double _toDouble(String v) {
    if (v.trim().isEmpty) return 0.0;
    final cleaned = v.replaceAll(',', '');
    try {
      return double.parse(cleaned);
    } catch (e) {
      final matches = RegExp(r'[\d.]+').allMatches(cleaned);
      if (matches.isEmpty) return 0.0;
      final joined = matches.map((m) => m.group(0)).join();
      return double.tryParse(joined) ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // fallback for AppColors if not available (safe default)
    final accent = (AppColors.primaryColor);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content
            Positioned.fill(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 12),
                    _buildIntroCard(),
                    const SizedBox(height: 12),
                    _buildEstimateCard(),
                    const SizedBox(height: 12),
                    _buildAnnexureCard('Annexure I', annexureI),
                    const SizedBox(height: 12),
                    _buildAnnexureCard('Annexure II', annexureII),
                    const SizedBox(height: 12),
                    _buildAnnexureCard('Annexure III', annexureIII),
                    const SizedBox(height: 100), // spacing for bottom bar
                  ],
                ),
              ),
            ),

            // Sticky bottom bar with Grand Total + Submit
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'GRAND TOTAL',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            formatCurrency(grandTotal),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final snack =
                                'Submitted. Grand total: ${formatCurrency(grandTotal)}';
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(snack)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI building blocks ----------------

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            decoration:
            BoxDecoration(color: AppColors.cardbg, shape: BoxShape.circle),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.arrow_back_ios_new, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Property Cost Calculator',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardbg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.calculate, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Estimate Total Cost',
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text(
                  'Fill in the property details and cost breakdown below to get an accurate estimate of the total unit cost.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardbg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Estimate Total Cost'),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _smallLabelField('Developer Name', developerCtrl)),
              const SizedBox(width: 10),
              Expanded(child: _smallLabelField('Project Name', projectCtrl)),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabel('Property Type'),
          const SizedBox(height: 8),
          _choiceChips(['Residential', 'Commercial', 'Others'], propertyTypeIndex,
                  (i) => setState(() => propertyTypeIndex = i)),
          const SizedBox(height: 12),
          _buildLabel('Payment Plan'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('Construction Link Plan'),
              _pill('Down Payment Plan'),
              _pill('Flexi Plan'),
              _pill('Special Payment Plan (Specify)'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _smallLabelField('Location (required)', locationCtrl)),
              const SizedBox(width: 10),
              Expanded(child: _smallLabelField('Size (required)', sizeCtrl)),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabel('Price Per Unit (required)'),
          const SizedBox(height: 8),
          Row(
            children: [
              _unitChoice('Sqft', 0),
              const SizedBox(width: 8),
              _unitChoice('Sqyrds', 1),
              const SizedBox(width: 8),
              _unitChoice('Sqmtrs', 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardTitle(String t) {
    return Row(
      children: [
        Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildLabel(String text) =>
      Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600));

  Widget _smallLabelField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),

        SizedBox(
          height: 44,
          child: TextField(
            controller: ctrl,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

              // 🔹 DEFAULT BORDER
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.lightBorder,
                  width: 1.2,
                ),
              ),

              // 🔹 ENABLED BORDER
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.lightBorder,
                  width: 1.2,
                ),
              ),

              // 🔹 FOCUSED BORDER (GREEN – FULL HEIGHT)
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primaryColor, // green
                  width: 1.6,
                ),
              ),

              hintText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _choiceChips(List<String> labels, int selected, Function(int) onTap) {
    return Row(
      children: List.generate(labels.length, (i) {
        final bool active = i == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              margin: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: active ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: active ? AppColors.primaryColor : AppColors.lightBorder)),
              child: Text(labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: active ? Colors.black : Colors.black87,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        );
      }),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _unitChoice(String label, int idx) {
    final bool active = unitIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => unitIndex = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: active ? AppColors.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: active ? AppColors.primaryColor : AppColors.lightBorder)),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: active ? Colors.black : Colors.black87,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // ---------------- FIXED Annexure Input Box used in rows ----------------
  Widget annexureInputBox(
      TextEditingController controller,
      Function(String) onChanged,
      ) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        keyboardType:
        const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        cursorColor: Colors.black,
        style: const TextStyle(fontSize: 13, color: Colors.black),

        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 8),

          // 🔹 NORMAL BORDER
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xffc8e9dd),
              width: 1.2,
            ),
          ),

          // 🔹 ENABLED BORDER
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xffc8e9dd),
              width: 1.2,
            ),
          ),

          // 🔹 FOCUSED BORDER (FULL GREEN)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xff28E29A), // green
              width: 1.6,
            ),
          ),

          hintText: "0",
          hintStyle:
          const TextStyle(fontSize: 13, color: Colors.black54),
        ),

        onChanged: onChanged,
      ),
    );
  }


  // Annexure card with table-like layout (updated to use annexureInputBox)
  Widget _buildAnnexureCard(String title, List<AnnexureRow> rows) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// ------- HEADER (Light Blue) --------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xffeaf5ff),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.expand_more, color: Colors.black54),
              ],
            ),
          ),

          /// ----- COLUMN HEADERS -----
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: const [
                Expanded(
                  flex: 5,
                  child: Text(
                    "PARTICULARS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "PRICE/UNIT",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "UNITS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "AMOUNT",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xffe0e0e0)),

          /// ------- ROWS SAME AS SCREENSHOT --------
          Column(
            children: List.generate(rows.length, (i) {
              final r = rows[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xfff1f1f1), width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// --- Particular Name ---
                    Expanded(
                      flex: 5,
                      child: Text(
                        "${i + 1}. ${r.name}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// --- Price Input ---
                    Expanded(
                      flex: 3,
                      child: annexureInputBox(r.priceCtrl, (v) {
                        r.price = _toDouble(v);
                        setState(() {});
                      }),
                    ),

                    const SizedBox(width: 10), // PERFECT SPACE

                    /// --- Units Input ---
                    Expanded(
                      flex: 2,
                      child: annexureInputBox(r.unitsCtrl, (v) {
                        r.units = _toDouble(v);
                        setState(() {});
                      }),
                    ),

                    const SizedBox(width: 10),

                    /// --- Amount (auto) ---
                    Expanded(
                      flex: 2,
                      child: Text(
                        formatCurrency(r.price * r.units),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          /// Bottom Total ROW
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xfff9f9f9),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Text(
                  "TOTAL",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  formatCurrency(rows.fold(0.0, (sum, r) => sum + (r.price * r.units))),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Model for annexure row
class AnnexureRow {
  final String name;
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController unitsCtrl = TextEditingController();
  double price = 0.0;
  double units = 0.0;

  AnnexureRow({required this.name});

  void dispose() {
    priceCtrl.dispose();
    unitsCtrl.dispose();
  }
}
