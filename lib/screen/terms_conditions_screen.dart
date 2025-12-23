import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/widget/custombottomnavbar.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
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
                      'Terms & conditions',
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
                          'assets/images/terms.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.description,
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
                              'I. GENERAL',
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
    return Text(
      '''This document is an electronic record in terms of Information Technology Act, 2000 and rules there under as applicable and the amended provisions pertaining to electronic records in various statutes as amended by the Information Technology Act, 2000. This electronic record is generated by a computer system and does not require any physical or digital signatures.

This document is published in accordance with the provisions of Rule 3 (1) of the Information Technology (Intermediaries guidelines) Rules, 2011 that require publishing the rules and regulations, privacy policy and Terms of Use for access or usage of the website huntproperty.com ("Website").

The Website is owned and operated by Catalyst E Pages Pvt. Ltd. ("Service Provider"), a company incorporated under the Companies Act, 2013, having its registered office at [Address], India.

DEFINITIONS

"You & User" shall mean any natural or legal person who has agreed to become a user of the Website by providing Registration Data while registering on the Website as Registered User using the computer systems. The term "You" or "User" shall include any natural or legal person who browses the Website or uses the services provided by the Website.

"We", "Us", "Our" shall mean the Service Provider.

"Party" shall mean either You or Us, as the case may be, and "Parties" shall mean both You and Us.

The section headings are for organizational purposes only and have no legal or contractual value.

By accessing or using the Website, You agree to be bound by these Terms and the Privacy Policy. If You do not agree to these Terms, please do not use the Website.

The Service Provider reserves the right to amend or modify these Terms at any time. Your continued use of the Website after any such changes constitutes Your acceptance of the new Terms.

You are granted a personal, non-exclusive, non-transferable, revocable, limited privilege to enter and use the Website.

The Website provides a platform for property listings, property search, and related services. The Service Provider acts as an intermediary and does not guarantee the accuracy, completeness, or reliability of any information provided on the Website.

You agree to use the Website only for lawful purposes and in accordance with these Terms. You agree not to use the Website in any way that violates any applicable law or regulation.

The Service Provider reserves the right to suspend or terminate Your access to the Website at any time, with or without cause or notice, for any reason including, but not limited to, breach of these Terms.

All content on the Website, including but not limited to text, graphics, logos, images, and software, is the property of the Service Provider or its content suppliers and is protected by copyright and other intellectual property laws.

You may not reproduce, distribute, modify, create derivative works of, publicly display, publicly perform, republish, download, store, or transmit any of the material on the Website without the prior written consent of the Service Provider.

The Service Provider may provide links to third-party websites or services. The Service Provider is not responsible for the content, privacy policies, or practices of any third-party websites or services.

You agree to indemnify and hold harmless the Service Provider, its affiliates, officers, directors, employees, and agents from any claims, damages, losses, liabilities, and expenses (including attorneys' fees) arising out of or relating to Your use of the Website or violation of these Terms.

The Service Provider makes no warranties, express or implied, regarding the Website or its content. The Website is provided "as is" and "as available" without warranty of any kind.

In no event shall the Service Provider be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of profits, data, or use, arising out of or relating to Your use of the Website.

These Terms shall be governed by and construed in accordance with the laws of India. Any disputes arising out of or relating to these Terms shall be subject to the exclusive jurisdiction of the courts in [City], India.

If any provision of these Terms is found to be invalid or unenforceable, the remaining provisions shall continue to be valid and enforceable to the fullest extent permitted by law.

These Terms constitute the entire agreement between You and the Service Provider regarding Your use of the Website and supersede all prior agreements and understandings.

The Service Provider's failure to enforce any right or provision of these Terms shall not constitute a waiver of such right or provision.

You may not assign or transfer these Terms or Your rights or obligations hereunder without the prior written consent of the Service Provider.

The Service Provider may assign or transfer these Terms or its rights or obligations hereunder without Your consent.

These Terms are effective as of the date You first access or use the Website and will remain in effect until terminated in accordance with these Terms.''',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        height: 1.6,
      ),
    );
  }
}

