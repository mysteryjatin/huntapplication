import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/screen/sidemenu_screen/faq_screen.dart';
import '../../cubit/home_loan_cubit.dart';
import '../../cubit/home_loan_state.dart';
import '../../data/repository/home_loan_repository.dart';
import 'package:hunt_property/screen/sidemenu_screen/property_cost_calculator.dart';
import 'package:hunt_property/screen/sidemenu_screen/financial_calculators_screen.dart';

class HomeLoanScreen extends StatefulWidget {
  const HomeLoanScreen({super.key});

  @override
  State<HomeLoanScreen> createState() => _HomeLoanScreenState();
}

class _HomeLoanScreenState extends State<HomeLoanScreen> {
  int selectedIndex = 0;

  final List<String> loanTypes = [
    "Home Loan",
    "Commercial Loan",
    "Residential Loan"
  ];
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  // replace with actual user id from auth/session
  final String _userId = '507f1f77bcf86cd799439012';
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeLoanCubit(repository: HomeLoanRepository()),
      child: Scaffold(
      backgroundColor: Colors.white,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

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
              "Home Loan",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),

            const Spacer(),
          ],
        ),
      ),

      // ---------------- BODY ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= MAIN CARD =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F7FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.black.withOpacity(0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/images/homeloan.png",
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "APPLY LOAN",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ---------------- LOAN TYPE TABS ----------------
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(loanTypes.length, (index) {
                      final isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF07E298)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF07E298)
                                  : Colors.black26,
                              width: 1.4,
                            ),
                          ),
                          child: Text(
                            loanTypes[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  /// ---------------- FORM ----------------
                  _inputField("Name (required)", controller: _nameController),
                  const SizedBox(height: 14),
                  _inputField("Email (required)", controller: _emailController),
                  const SizedBox(height: 14),
                  _inputField("Phone number (required)", controller: _phoneController),
                  const SizedBox(height: 14),
                  _inputField("Address (required)", controller: _addressController, maxLines: 2),

                  const SizedBox(height: 10),

                  /// FAQ LINK
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQScreen(),
                        ),
                      );
                    },
                    child: Center(
                      child: Text(
                        "How it Works/FAQ",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ---------------- SUBMIT BUTTON ----------------
                  BlocConsumer<HomeLoanCubit, HomeLoanState>(
                    listener: (context, state) {
                      if (state.status == HomeLoanStatus.success) {
                        // clear inputs on success
                        _nameController.clear();
                        _emailController.clear();
                        _phoneController.clear();
                        _addressController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Application submitted successfully')),
                        );
                      } else if (state.status == HomeLoanStatus.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Submission failed: ${state.error}')),
                        );
                      }
                    },
                    builder: (context, state) {
                      final submitting = state.status == HomeLoanStatus.submitting;
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF07E298),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MaterialButton(
                          onPressed: submitting
                              ? null
                              : () {
                                  final name = _nameController.text.trim();
                                  final email = _emailController.text.trim();
                                  final phone = _phoneController.text.trim();
                                  final address = _addressController.text.trim();

                                  String? error;
                                  bool isValidEmail(String e) {
                                    final regex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
                                    return regex.hasMatch(e);
                                  }

                                  if (name.isEmpty) {
                                    error = 'Please enter name';
                                  } else if (email.isEmpty) {
                                    error = 'Please enter email';
                                  } else if (!isValidEmail(email)) {
                                    error = 'Please enter a valid email';
                                  } else if (phone.isEmpty) {
                                    error = 'Please enter phone number';
                                  } else if (address.isEmpty) {
                                    error = 'Please enter address';
                                  }

                                  if (error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                    return;
                                  }

                                  final cubit = context.read<HomeLoanCubit>();
                                  cubit.submit(
                                    loanType: loanTypes[selectedIndex],
                                    name: name,
                                    email: email,
                                    phone: phone,
                                    address: address,
                                    userId: _userId,
                                  );
                                },
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: submitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            /// ================= OTHER CALCULATOR =================
            const Text(
              "Other Calculator",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            _calcButton("Home Loan Calculator"),
            _calcButton("Property Cost Calculator"),
            _calcButton("Rental value Calculator"),
            _calcButton("Future value Calculator"),

            const SizedBox(height: 100),
          ],
        ),
      ),
    ));
  }

  // ================= INPUT FIELD (SAME AS IMAGE) =================
  Widget _inputField(String label, {int maxLines = 1, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: (label.toLowerCase().contains('phone') || label.toLowerCase().contains('mobile') || label.toLowerCase().contains('number'))
                ? TextInputType.phone
                : TextInputType.text,
            inputFormatters: (label.toLowerCase().contains('phone') || label.toLowerCase().contains('mobile') || label.toLowerCase().contains('number'))
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ================= OTHER CALCULATOR BUTTON =================
  Widget _calcButton(String title) {
    VoidCallback? onTap;
    if (title.toLowerCase().contains('home loan')) {
      onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialCalculatorsScreen(initialTabIndex: 0)));
    } else if (title.toLowerCase().contains('property cost')) {
      onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertyCostCalculatorScreen()));
    } else if (title.toLowerCase().contains('rental')) {
      onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialCalculatorsScreen(initialTabIndex: 1)));
    } else if (title.toLowerCase().contains('future')) {
      onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialCalculatorsScreen(initialTabIndex: 2)));
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
