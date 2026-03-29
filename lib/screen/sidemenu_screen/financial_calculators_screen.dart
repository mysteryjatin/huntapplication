import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/financial_calculators_repository.dart';
import '../../cubit/financial_calculators_cubit.dart';
import '../../cubit/financial_calculators_state.dart';
import '../../theme/app_theme.dart';

class FinancialCalculatorsScreen extends StatefulWidget {
  final int initialTabIndex;
  const FinancialCalculatorsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<FinancialCalculatorsScreen> createState() =>
      _FinancialCalculatorsScreenState();
}

class _FinancialCalculatorsScreenState extends State<FinancialCalculatorsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabResetTrigger = 0;
  int _prevTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTabIndex);
    _prevTabIndex = widget.initialTabIndex;
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final current = _tabController.index;
    if (current != _prevTabIndex) {
      _prevTabIndex = current;
      setState(() => _tabResetTrigger++);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinancialCalculatorsCubit(repository: FinancialCalculatorsRepository()),
      child: Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
      children: [
      GestureDetector(
      onTap: () => Navigator.pop(context),
    child: const CircleAvatar(
    radius: 18,
    backgroundColor: Color(0xFFF2F4F7),
    child: Icon(
    Icons.arrow_back_ios_new,
    size: 16,
    color: Colors.black,
    ),
    ),
    ),

    const Spacer(),

    Text(
    "Financial Calculators",
    style: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: Colors.black,
    ),
    ),

    const Spacer(),
    ],
    ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFFF2F9FF),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              indicatorColor: const Color(0xFF28E29A),
              indicatorWeight: 2.5,

              // Selected tab
              labelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),

              // Unselected tab
              unselectedLabelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),

              tabs: const [
                Tab(text: 'Loan Eligibility'),
                Tab(text: 'Rental Value'),
                Tab(text: 'Future Value'),
                Tab(text: 'EMI'),
              ],
            ),
          ),
        ),

      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LoanEligibilityTab(resetTrigger: _tabResetTrigger),
          RentalValueTab(resetTrigger: _tabResetTrigger),
          FutureValueTab(resetTrigger: _tabResetTrigger),
          EmiTab(resetTrigger: _tabResetTrigger),
        ],
      ),
      )    );
  }
}

// ================= COMMON INPUT =================

class AppInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const AppInput(this.label, {
    required this.controller,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE3E3E3)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Max 2 digits (1-99) for Year/Rate fields
final _max2Digits = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(2),
];

/// Property value (₹): digits and commas only, **no character limit** (only > 0 validated).
final _propertyValueInput = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
];

// ================= GREEN BUTTON =================

class GreenButton extends StatelessWidget {
  final String text;
  const GreenButton(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF28E29A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

// ================= RESULT CARD =================

/// Themed error state for calculator API failures (FastAPI / validation messages).
Widget calculatorErrorCard(String message) {
  return resultCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.redcolor.withOpacity(0.12),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.redcolor,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
              height: 1.35,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget resultCard({required Widget child, Key? key}) {
  return Container(
    key: key,
    width: double.infinity,
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE3E3E3)),
    ),
    child: child,
  );
}

// ================= LOAN ELIGIBILITY =================

class LoanEligibilityTab extends StatefulWidget {
  final int resetTrigger;
  const LoanEligibilityTab({super.key, required this.resetTrigger});

  @override
  State<LoanEligibilityTab> createState() => _LoanEligibilityTabState();
}

class _LoanEligibilityTabState extends State<LoanEligibilityTab> {
  final _loanRequired = TextEditingController();
  final _netIncome = TextEditingController();
  final _existingCommitments = TextEditingController();
  final _tenureYears = TextEditingController();
  final _tenureMonths = TextEditingController();
  final _rate = TextEditingController();

  @override
  void didUpdateWidget(covariant LoanEligibilityTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetTrigger != widget.resetTrigger) {
      _loanRequired.clear();
      _netIncome.clear();
      _existingCommitments.clear();
      _tenureYears.clear();
      _tenureMonths.clear();
      _rate.clear();
      // Clear any previous calculator results when switching tabs
      context.read<FinancialCalculatorsCubit>().resetAll();
    }
  }

  @override
  void dispose() {
    _loanRequired.dispose();
    _netIncome.dispose();
    _existingCommitments.dispose();
    _tenureYears.dispose();
    _tenureMonths.dispose();
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FinancialCalculatorsCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppInput('Loan Required (₹)', controller: _loanRequired),
          AppInput('Net income per month (₹)', controller: _netIncome),
          AppInput('Existing loan commitments (₹)', controller: _existingCommitments),
          // Loan Tenure with Years + Months (design as per screenshot)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loan Tenure',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Years box
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE3E3E3)),
                        ),
                        child: TextField(
                          controller: _tenureYears,
                          keyboardType: TextInputType.number,
                          inputFormatters: _max2Digits,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            hintText: 'Years',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Months box
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE3E3E3)),
                        ),
                        child: TextField(
                          controller: _tenureMonths,
                          keyboardType: TextInputType.number,
                          inputFormatters: _max2Digits,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            hintText: 'Months',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppInput('Rate of Interest (%)', controller: _rate, keyboardType: TextInputType.number, inputFormatters: _max2Digits),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (cubit.state.status == CalcStatus.loading) return;
                  // Basic validation so backend ko 0 values na jayein.
                  String? error;

                  final loanRequired =
                      int.tryParse(_loanRequired.text.trim());
                  if (loanRequired == null || loanRequired <= 0) {
                    error = 'Please enter Loan Required greater than 0';
                  }

                  final netIncome =
                      int.tryParse(_netIncome.text.trim());
                  if (error == null &&
                      (netIncome == null || netIncome <= 0)) {
                    error = 'Please enter Net income per month greater than 0';
                  }

                  final existing = int.tryParse(
                          _existingCommitments.text.trim()) ??
                      0;

                  final years =
                      int.tryParse(_tenureYears.text.trim()) ?? 0;
                  final months =
                      int.tryParse(_tenureMonths.text.trim()) ?? 0;

                  final totalYears =
                      years + (months / 12.0);

                  if (error == null && years <= 0 && months <= 0) {
                    error = 'Please enter Loan Tenure (years or months)';
                  }
                  if (error == null && totalYears < 0.5) {
                    error =
                        'Loan tenure must be at least 6 months (0.5 years)';
                  }

                  final rate =
                      num.tryParse(_rate.text.trim());
                  if (error == null &&
                      (rate == null || rate <= 0)) {
                    error = 'Please enter Rate of Interest greater than 0';
                  }
                  if (error == null && rate != null && rate > 99) {
                    error = 'Rate must be 1-99%';
                  }
                  if (error == null && months > 12) {
                    error = 'Months must be 0-12';
                  }

                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error!)),
                    );
                    return;
                  }

                  cubit.checkLoanEligibility(
                    loanRequired: loanRequired!,
                    netIncomePerMonth: netIncome!,
                    existingLoanCommitments: existing,
                    loanTenureYears: totalYears,
                    rateOfInterest: rate!,
                  );
                },
                child: const GreenButton('Check Eligibility'),
              ),
              GestureDetector(
                onTap: () {
                  _loanRequired.clear();
                  _netIncome.clear();
                  _existingCommitments.clear();
                  _tenureYears.clear();
                  _tenureMonths.clear();
                  _rate.clear();
                  cubit.resetAll();
                },
                child: const Text('Reset all', style: TextStyle(fontSize: 12, color: Colors.black)),
              ),
            ],
          ),

          BlocBuilder<FinancialCalculatorsCubit, FinancialCalculatorsState>(
            bloc: cubit,
            buildWhen: (prev, curr) =>
                prev.status != curr.status ||
                prev.loanEligibility != curr.loanEligibility,
            builder: (context, state) {
              if (state.status == CalcStatus.loading) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state.status == CalcStatus.failure) {
                return calculatorErrorCard(
                  state.error ?? 'Eligibility check failed',
                );
              }

              if (state.loanEligibility == null) {
                return resultCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text('Enter details above and tap "Check Eligibility"', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                    ],
                  ),
                );
              }

              final d = state.loanEligibility!;
              return resultCard(
                key: ValueKey('loan_${d.maximumEligibleAmount}_${d.maximumEmi}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: d.eligible ? const Color(0xFFE8FFF0) : const Color(0xFFFFE5E5),
                      child: Icon(
                        d.eligible ? Icons.check : Icons.info_outline,
                        color: d.eligible ? Colors.green : Colors.red,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      d.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Maximum eligible amount: ₹${d.maximumEligibleAmount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Maximum EMI: ₹${d.maximumEmi}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

// ================= RENTAL VALUE =================

class RentalValueTab extends StatefulWidget {
  final int resetTrigger;
  const RentalValueTab({super.key, required this.resetTrigger});

  @override
  State<RentalValueTab> createState() => _RentalValueTabState();
}

class _RentalValueTabState extends State<RentalValueTab> {
  final _propertyValue = TextEditingController();
  final _years = TextEditingController();
  final _rate = TextEditingController();

  @override
  void initState() {
    super.initState();
    // API returns annual rent only; total over N years is annual × years. Rebuild when
    // years change so the headline updates without requiring ROI/property to change.
    _years.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant RentalValueTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetTrigger != widget.resetTrigger) {
      _propertyValue.clear();
      _years.clear();
      _rate.clear();
      context.read<FinancialCalculatorsCubit>().resetAll();
    }
  }

  @override
  void dispose() {
    _propertyValue.dispose();
    _years.dispose();
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FinancialCalculatorsCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppInput(
            'Property Value (₹)',
            controller: _propertyValue,
            inputFormatters: _propertyValueInput,
          ),
          AppInput('Year', controller: _years, inputFormatters: _max2Digits),
          AppInput('Rate of Rent (%)', controller: _rate, inputFormatters: _max2Digits),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (cubit.state.status == CalcStatus.loading) return;
                  String? error;

                  final pvClean = _propertyValue.text
                      .trim()
                      .replaceAll(RegExp(r'[,\s]'), '');
                  final propertyValue = num.tryParse(pvClean);
                  if (propertyValue == null || propertyValue <= 0) {
                    error = 'Please enter Property Value greater than 0';
                  }

                  final years =
                      int.tryParse(_years.text.trim());
                  if (error == null &&
                      (years == null || years < 1)) {
                    error = 'Please enter Years at least 1';
                  }
                  if (error == null && years != null && years > 99) {
                    error = 'Year must be 1-99';
                  }

                  final rate =
                      num.tryParse(_rate.text.trim());
                  if (error == null &&
                      (rate == null || rate <= 0)) {
                    error = 'Please enter Rate of Rent greater than 0';
                  }
                  if (error == null && rate != null && rate > 30) {
                    error = 'Rate of rent must be between 1% and 30%';
                  }

                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error!)),
                    );
                    return;
                  }

                  cubit.checkRentalValue(
                    propertyValue: propertyValue!,
                    rateOfRent: rate!,
                    years: years!,
                  );
                },
                child: const GreenButton('Check Value'),
              ),
              GestureDetector(
                onTap: () {
                  _propertyValue.clear();
                  _years.clear();
                  _rate.clear();
                  cubit.resetAll();
                },
                child: const Text('Reset all', style: TextStyle(fontSize: 12, color: Colors.black)),
              ),
            ],
          ),

          BlocBuilder<FinancialCalculatorsCubit, FinancialCalculatorsState>(
            bloc: cubit,
            buildWhen: (prev, curr) =>
                prev.status != curr.status ||
                prev.rentalValue != curr.rentalValue,
            builder: (context, state) {
              if (state.status == CalcStatus.loading) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state.status == CalcStatus.failure) {
                return calculatorErrorCard(
                  state.error ?? 'Could not calculate rental value',
                );
              }
              if (state.rentalValue == null) {
                return resultCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          'Enter property details above and tap "Check Value"',
                          style: TextStyle(fontSize: 13, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '₹0',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final d = state.rentalValue!;
              final yearsParsed = int.tryParse(_years.text.trim());
              final yearsForTotal = (yearsParsed != null &&
                      yearsParsed >= 1 &&
                      yearsParsed <= 99)
                  ? yearsParsed
                  : 1;
              // Backend returns yearly rent; multiply by years for total contract value.
              final totalForPeriod = d.rentalValueAnnual * yearsForTotal;
              return resultCard(
                key: ValueKey(
                    'rental_${d.rentalValueAnnual}_${d.rentalValueMonthly}_y$yearsForTotal'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        yearsForTotal == 1
                            ? 'Your annual rental value is'
                            : 'Your total rental value ($yearsForTotal years)',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '₹$totalForPeriod',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Annual: ₹${d.rentalValueAnnual} · Monthly: ₹${d.rentalValueMonthly}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

// ================= FUTURE VALUE =================

class FutureValueTab extends StatefulWidget {
  final int resetTrigger;
  const FutureValueTab({super.key, required this.resetTrigger});

  @override
  State<FutureValueTab> createState() => _FutureValueTabState();
}

class _FutureValueTabState extends State<FutureValueTab> {
  final _currentValue = TextEditingController();
  final _years = TextEditingController();
  final _appreciation = TextEditingController();

  @override
  void didUpdateWidget(covariant FutureValueTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetTrigger != widget.resetTrigger) {
      _currentValue.clear();
      _years.clear();
      _appreciation.clear();
      context.read<FinancialCalculatorsCubit>().resetAll();
    }
  }

  @override
  void dispose() {
    _currentValue.dispose();
    _years.dispose();
    _appreciation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FinancialCalculatorsCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppInput('Current property value (₹)', controller: _currentValue),
          AppInput('No. of year', controller: _years, inputFormatters: _max2Digits),
          AppInput('Average appreciation (%)', controller: _appreciation, inputFormatters: _max2Digits),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (cubit.state.status == CalcStatus.loading) return;
                  String? error;

                  final currentValue =
                      int.tryParse(_currentValue.text.trim());
                  if (currentValue == null || currentValue <= 0) {
                    error =
                        'Please enter Current property value greater than 0';
                  }

                  final years =
                      int.tryParse(_years.text.trim());
                  if (error == null &&
                      (years == null || years < 1)) {
                    error = 'Please enter Years at least 1';
                  }

                  final appreciation =
                      num.tryParse(_appreciation.text.trim());
                  if (error == null &&
                      (appreciation == null || appreciation <= 0)) {
                    error = 'Please enter Average appreciation greater than 0';
                  }
                  if (error == null && years != null && years > 99) {
                    error = 'Year must be 1-99';
                  }
                  if (error == null && appreciation != null && appreciation > 99) {
                    error = 'Rate must be 1-99%';
                  }

                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error!)),
                    );
                    return;
                  }

                  final payload = {
                    // backend expects 'current_property_value'
                    'current_property_value': currentValue,
                    'years': years,
                    'average_appreciation': appreciation,
                  };
                  cubit.checkFutureValue(payload);
                },
                child: const GreenButton('Check Value'),
              ),
              GestureDetector(
                onTap: () {
                  _currentValue.clear();
                  _years.clear();
                  _appreciation.clear();
                  cubit.resetAll();
                },
                child: const Text('Reset all', style: TextStyle(fontSize: 12, color: Colors.black)),
              ),
            ],
          ),

          BlocBuilder<FinancialCalculatorsCubit, FinancialCalculatorsState>(
            bloc: cubit,
            buildWhen: (prev, curr) =>
                prev.status != curr.status ||
                prev.futureValue != curr.futureValue,
            builder: (context, state) {
              if (state.status == CalcStatus.loading) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state.status == CalcStatus.failure) {
                return calculatorErrorCard(
                  state.error ?? 'Could not calculate future value',
                );
              }
              if (state.futureValue == null) {
                return resultCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text('Enter current value and tap "Check Value"', style: TextStyle(fontSize: 12, color: Colors.black)),
                      SizedBox(height: 6),
                      Text('₹0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
                    ],
                  ),
                );
              }

              final d = state.futureValue!;
              final display = d['future_value'] ?? d;
              return resultCard(
                key: ValueKey('future_$display'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Future value', style: TextStyle(fontSize: 12, color: Colors.black)),
                    const SizedBox(height: 6),
                    Text('₹$display', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ================= EMI =================

class EmiTab extends StatefulWidget {
  final int resetTrigger;
  const EmiTab({super.key, required this.resetTrigger});

  @override
  State<EmiTab> createState() => _EmiTabState();
}

class _EmiTabState extends State<EmiTab> {
  final _loanAmount = TextEditingController();
  final _tenure = TextEditingController();
  final _rate = TextEditingController();

  @override
  void didUpdateWidget(covariant EmiTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetTrigger != widget.resetTrigger) {
      _loanAmount.clear();
      _tenure.clear();
      _rate.clear();
      context.read<FinancialCalculatorsCubit>().resetAll();
    }
  }

  @override
  void dispose() {
    _loanAmount.dispose();
    _tenure.dispose();
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FinancialCalculatorsCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppInput('Loan Amount (₹)', controller: _loanAmount),
          AppInput('Loan Tenure (years)', controller: _tenure, inputFormatters: _max2Digits),
          AppInput('Rate of Interest (%)', controller: _rate, inputFormatters: _max2Digits),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (cubit.state.status == CalcStatus.loading) return;
                  String? error;

                  final loanAmount =
                      int.tryParse(_loanAmount.text.trim());
                  if (loanAmount == null || loanAmount <= 0) {
                    error = 'Please enter Loan Amount greater than 0';
                  }

                  final tenure =
                      int.tryParse(_tenure.text.trim());
                  if (error == null &&
                      (tenure == null || tenure < 1)) {
                    error = 'Loan tenure must be at least 1 year';
                  }
                  if (error == null && tenure != null && tenure > 99) {
                    error = 'Tenure must be 1-99 years';
                  }

                  final rate =
                      num.tryParse(_rate.text.trim());
                  if (error == null &&
                      (rate == null || rate <= 0)) {
                    error = 'Please enter Rate of Interest greater than 0';
                  }
                  if (error == null && rate != null && rate > 99) {
                    error = 'Rate must be 1-99%';
                  }

                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error!)),
                    );
                    return;
                  }

                  cubit.checkEmi(
                    loanAmount: loanAmount!,
                    loanTenureYears: tenure!,
                    rateOfInterest: rate!,
                  );
                },
                child: const GreenButton('Check EMI'),
              ),
              GestureDetector(
                onTap: () {
                  _loanAmount.clear();
                  _tenure.clear();
                  _rate.clear();
                  cubit.resetAll();
                },
                child: const Text('Reset all', style: TextStyle(fontSize: 12, color: Colors.black)),
              ),
            ],
          ),

          BlocBuilder<FinancialCalculatorsCubit, FinancialCalculatorsState>(
            bloc: cubit,
            buildWhen: (prev, curr) =>
                prev.status != curr.status ||
                prev.emi != curr.emi,
            builder: (context, state) {
              if (state.status == CalcStatus.loading) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.status == CalcStatus.initial) {
                return resultCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('Monthly EMI', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 6),
                      Text('₹0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }

              if (state.status == CalcStatus.failure) {
                return calculatorErrorCard(
                  state.error ?? 'Could not calculate EMI',
                );
              }
              if (state.emi == null) {
                return resultCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('Monthly EMI', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 6),
                      Text('₹0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }

              final d = state.emi!;
              return resultCard(
                key: ValueKey('emi_${d.monthlyEmi}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Monthly EMI', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text('₹${d.monthlyEmi}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF28E29A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Apply for Loan', style: TextStyle(color: Colors.black)),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
// TOP BACK BUTTON + HEADING
// -----------------------------------------
Widget _appBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xfff1f7ff),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: Colors.black),
          ),
        ),
        const SizedBox(width: 20),
        const Expanded(
          child: Text(
            "Channel Partner",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    ),
  );
}
