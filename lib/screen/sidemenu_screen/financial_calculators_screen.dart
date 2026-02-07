import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancialCalculatorsScreen extends StatefulWidget {
  const FinancialCalculatorsScreen({super.key});

  @override
  State<FinancialCalculatorsScreen> createState() =>
      _FinancialCalculatorsScreenState();
}

class _FinancialCalculatorsScreenState extends State<FinancialCalculatorsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        children: const [
          LoanEligibilityTab(),
          RentalValueTab(),
          FutureValueTab(),
          EmiTab(),
        ],
      ),
    );
  }
}

// ================= COMMON INPUT =================

class AppInput extends StatelessWidget {
  final String label;
  const AppInput(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),

          // INPUT BOX
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE3E3E3)),
            ),
            child: const TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

Widget resultCard({required Widget child}) {
  return Container(
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

class LoanEligibilityTab extends StatelessWidget {
  const LoanEligibilityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const AppInput('Loan Required (₹)'),
          const AppInput('Net income per month (₹)'),
          const AppInput('Existing loan commitments (₹)'),
          const AppInput('Loan Tenure (years)'),
          const AppInput('Rate of Interest (%)'),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              GreenButton('Check Eligibility'),
              Text('Reset all',
                  style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),

      resultCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            // Icon
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFFFE5E5),
              child: Icon(
                Icons.info_outline,
                color: Colors.red,
                size: 22,
              ),
            ),

            SizedBox(height: 12),

            // Title
            Text(
              'Eligibility Check Failed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 6),

            // Subtitle
            Text(
              'Maximum eligible amount: ₹0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )

      ],
      ),
    );
  }
}

// ================= RENTAL VALUE =================

class RentalValueTab extends StatelessWidget {
  const RentalValueTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const AppInput('Property Value (₹)'),
          const AppInput('Year (per month)'),
          const AppInput('Rate of Rent (%)'),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              GreenButton('Check Value'),
              Text('Reset all',
                  style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),

      resultCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                'Your rental value is',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '₹0',
                style: TextStyle(
                  fontSize: 22, // 👈 BIGGER AMOUNT
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      )

      ],
      ),
    );
  }
}

// ================= FUTURE VALUE =================

class FutureValueTab extends StatelessWidget {
  const FutureValueTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const AppInput('Current property value (₹)'),
          const AppInput('No. of year'),
          const AppInput('Average appreciation (%)'),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              GreenButton('Check Value'),
              Text('Reset all',
                  style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),

          resultCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text('Your rental value is',
                    style: TextStyle(fontSize: 12, color: Colors.black)),
                SizedBox(height: 6),
                Text(
                  '₹0',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700,color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= EMI =================

class EmiTab extends StatelessWidget {
  const EmiTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const AppInput('Loan Amount (₹)'),
          const AppInput('Loan Tenure (years)'),
          const AppInput('Rate of Interest (%)'),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              GreenButton('Check Eligibility'),
              Text('Reset all',
                  style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),

          resultCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Monthly EMI',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                const Text(
                  '₹33,038',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
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
                    child: const Text(
                      'Apply for Loan',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
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
