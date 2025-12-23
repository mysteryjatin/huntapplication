import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/widget/custombottomnavbar.dart';

class CancellationPolicyScreen extends StatefulWidget {
  const CancellationPolicyScreen({super.key});

  @override
  State<CancellationPolicyScreen> createState() => _CancellationPolicyScreenState();
}

class _CancellationPolicyScreenState extends State<CancellationPolicyScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(context),
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
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image at the top
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/images/cancellation.png',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.cancel,
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
                                'CANCELLATION POLICY',
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
            ),
          ],
        ),
      ),
      // bottomNavigationBar: CustomBottomNavBar(
      //   selectedIndex: _selectedNavIndex,
      //   onItemSelected: (index) {
      //     setState(() => _selectedNavIndex = index);
      //     // Navigate back to home screen when any tab is selected
      //     Navigator.popUntil(context, (route) => route.isFirst);
      //   },
      // ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '1. PAYMENT & REFUND CLAUSE',
          [
            'For all services bought, 50% of the order amount would be towards the activation/administration fees & the rest 50% would be refunded on pro-rata basis, considering the usages of the services. Customer agrees that the refund process would take at least 21 days after the complete documentation has been received by the Finance team for processing such refund.',
            'Where Subscription Fees accrues it shall be payable at or within such time as stated in the invoice(s) issued by the Company to the User.',
            'The Subscription Fees shall be paid by the User on demand. In case the user disputes the same for any reason whatsoever, he shall make the payment towards the Subscription Fees accrued subject to the decision of the Company on the dispute. In the event of Company\'s deciding the dispute in the User\'s favour, the Company shall refund to the User any excess amount paid by the User free of interest.',
            'Any delay in the payment by the User of any sums due under this Agreement, the Company shall have the right to charge interest on the outstanding amount from the date the payment became due until the date of final payment by the User.',
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          '2. PAYMENT SECURITY',
          [],
        ),
        const SizedBox(height: 20),
        _buildSection(
          '3. Transactions on the Website are secure and protected.',
          [
            'Any information entered by the User when transacting on the Website is encrypted to protect the User against unintentional disclosure to third parties. The User\'s credit and debit card information is not received, stored by or retained by the Service Provider / Website in any manner. This information is supplied by the User directly to the relevant payment gateway which is authorized to handle the information provided, and is compliant with the regulations and requirements of various banks and institutions and payment franchisees that it is associated with.',
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          '4. CHARGE BACK POLICY',
          [
            'Payment for the services offered shall be on 100% advance basis.',
            'Payment for service once subscribed to by the subscriber, is not refundable and any amount paid shall stand appropriated.',
            'Refund if any will be at the sole discretion of Catalyst E Pages Private Limited only.',
            'User acknowledges and agrees that Catalyst E Pages Private Limited at its sole discretion and without prejudice to other rights and remedies that it may have under the applicable laws, shall be entitled to set off the amount paid by a subscriber/user, against any amount(s) payable by user to Catalyst E Pages Private Limited under any other agreement or commercial relationship towards other products/services.',
            'Catalyst E Pages Private Limited offers no guarantees whatsoever for the accuracy or timeliness of the refunds reaching the Subscribers card/bank accounts. This is on account of the multiplicity of organizations involved in processing of online transactions, the problems with Internet infrastructure currently available and working days/holidays of financial institutions.',
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          '5. CANCELLATION',
          [
            'Company shall reserve the exclusive right to cancel any content whatsoever from being published or reflected on its website or in any other mode. The cancellation charges payable to the User shall be at the applicable rates laid down in the cancellation and refund policy.',
            'For all services bought, 25% of the order amount would be towards the activation/administration fees & the rest 75% would be refunded against cancellation on pro-rata basis, considering the usages of the services. Customer agrees that the cancellation process would take at least 21 days after the complete documentation has been received by the Finance team for processing such refund.',
            'All refund and cancellation will be process after deducting all government taxes, as once these taxes paid to government can not be claimed. So the customer agrees the terms of cancellation and refund process.',
            'Where Subscription Fees accrues it shall be payable at or within such time as stated in the invoice(s) issued by the Company to the User.',
            'The Subscription Fees shall be paid by the User on demand. In case the user disputes the same for any reason whatsoever, he shall make the payment towards the Subscription Fees accrued subject to the decision of the Company on the dispute. In the event of Company\'s deciding the dispute in the User\'s favour, the Company shall refund to the User any excess amount paid by the User free of interest.',
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

// ------------------ APP BAR ------------------
Widget _appBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardbg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: Colors.black),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            "Cancellation Policy",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    ),
  );
}