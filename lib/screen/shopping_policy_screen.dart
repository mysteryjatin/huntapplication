import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/widget/custombottomnavbar.dart';

class ShoppingPolicyScreen extends StatefulWidget {
  const ShoppingPolicyScreen({super.key});

  @override
  State<ShoppingPolicyScreen> createState() => _ShoppingPolicyScreenState();
}

class _ShoppingPolicyScreenState extends State<ShoppingPolicyScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with light gray background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  const Expanded(
                    child: Text(
                      'Shopping Policy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image at the top
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/images/shopping.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.shopping_cart,
                                size: 60,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),

                      // Text Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Shopping Policy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTextContent(),
                          ],
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onItemSelected: (index) {
          setState(() => _selectedNavIndex = index);
          // Navigate back to home screen when any tab is selected
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '1. CHARGES',
          [
            'Browsing the Website is free. However, the Service Provider reserves the right to charge for services availed through the Website. The Service Provider reserves the right to amend the charges for services offered through the Website at any time, with or without notice. The Service Provider will notify the User of any such changes and the User may decline to avail the services at the amended charges.',
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          '2. PACKAGES, FEES AND PAYMENT',
          [
            'Service activation requires full payment (Demand Draft, Debit Card, Credit Card, etc.) as per the Subscription Order. Liability for costs begins from the "start date" or date of acceptance.',
            'Credit card payments activate the service upon receipt of the first or sole payment.',
            'Monthly credit card payments for 12 or 6-month contracts require 2 or 4 security cheques, each for a pro rata amount.',
            'Security cheques must be provided before the first month\'s expiry, with failure leading to service suspension.',
            'A Rs1000 administration fee applies for bounced/rejected cheques, plus additional costs for failed payments or pursuing outstanding amounts.',
            'Fees are specified in the Subscription Order. Different packages are available, and the Service Provider has discretion regarding switching or adding conditions. Package reduction does not reduce the total fee until the contract term ends, but packages can be varied if the total value remains above the current fee.',
            'Membership suspension still incurs fee liability.',
            'The Service Provider reserves the right to amend Subscription Order terms (packages, fees) but not for existing contracts. Users are advised to retain a copy of the terms.',
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          '3. MODE OF PAYMENT',
          [
            'Available payment options include: Domestic and international credit cards (Visa, MasterCard, Amex), Visa & MasterCard Debit cards, and Netbanking/Direct Debit from select Indian banks. Available options will be shown at \'checkout\'.',
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (points.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}


