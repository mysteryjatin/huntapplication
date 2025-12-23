import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/widget/custombottomnavbar.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
                      'Privacy Policy',
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
                          'assets/images/privacy.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.privacy_tip,
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
      '''This Privacy Policy ("Policy") describes how Catalyst E Pages Pvt. Ltd. ("Service Provider", "We", "Us", or "Our") collects, uses, shares, and protects Your personal information when You use the website huntproperty.com ("Website"). This Policy is an electronic record in terms of Information Technology Act, 2000 and rules there under as applicable.

By accessing or using the Website, You agree to the collection and use of information in accordance with this Policy. If You do not agree with the data practices described in this Policy, You should not use the Website.

INFORMATION WE COLLECT

We collect information that You provide directly to Us when You:
• Register for an account on the Website
• Post property listings or advertisements
• Search for properties
• Contact Us through forms, email, or other means
• Subscribe to Our newsletters or promotional materials
• Participate in surveys or other interactive features

The types of personal information We may collect include:
• Name, email address, phone number, and postal address
• Property details and preferences
• Payment information (processed through secure third-party payment processors)
• Profile information and preferences
• Communications between You and Us
• Any other information You choose to provide

AUTOMATICALLY COLLECTED INFORMATION

When You visit the Website, We automatically collect certain information about Your device, including:
• IP address and location data
• Browser type and version
• Operating system
• Pages You visit and time spent on pages
• Referring website addresses
• Device identifiers
• Cookies and similar tracking technologies

HOW WE USE YOUR INFORMATION

We use the information We collect to:
• Provide, maintain, and improve the Website and Our services
• Process Your property listings and transactions
• Communicate with You about Your account, properties, and Our services
• Send You marketing communications (with Your consent)
• Respond to Your inquiries and provide customer support
• Detect, prevent, and address technical issues and fraudulent activities
• Comply with legal obligations and enforce Our terms of service
• Analyze usage patterns and trends to improve user experience

SHARING OF INFORMATION

We may share Your information in the following circumstances:
• With property buyers, sellers, and other users as necessary to facilitate property transactions
• With service providers who perform services on Our behalf (e.g., payment processing, data analytics)
• With business partners and affiliates for marketing purposes (with Your consent)
• When required by law or to respond to legal process
• To protect Our rights, property, or safety, or that of Our users or others
• In connection with a merger, acquisition, or sale of assets

We do not sell Your personal information to third parties for their marketing purposes.

DATA SECURITY

We implement appropriate technical and organizational measures to protect Your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the Internet or electronic storage is 100% secure, and We cannot guarantee absolute security.

COOKIES AND TRACKING TECHNOLOGIES

We use cookies and similar tracking technologies to track activity on Our Website and store certain information. You can instruct Your browser to refuse all cookies or to indicate when a cookie is being sent. However, if You do not accept cookies, You may not be able to use some portions of Our Website.

YOUR RIGHTS

You have the right to:
• Access and receive a copy of Your personal information
• Rectify inaccurate or incomplete information
• Request deletion of Your personal information
• Object to processing of Your personal information
• Request restriction of processing
• Data portability
• Withdraw consent at any time

To exercise these rights, please contact Us using the contact information provided below.

DATA RETENTION

We retain Your personal information for as long as necessary to fulfill the purposes outlined in this Policy, unless a longer retention period is required or permitted by law. When We no longer need Your information, We will securely delete or anonymize it.

THIRD-PARTY LINKS

The Website may contain links to third-party websites or services. We are not responsible for the privacy practices of such third parties. We encourage You to read the privacy policies of any third-party websites You visit.

CHILDREN'S PRIVACY

The Website is not intended for children under the age of 18. We do not knowingly collect personal information from children. If You are a parent or guardian and believe Your child has provided Us with personal information, please contact Us immediately.

CHANGES TO THIS POLICY

We may update this Privacy Policy from time to time. We will notify You of any changes by posting the new Policy on this page and updating the "Last Updated" date. You are advised to review this Policy periodically for any changes.

CONTACT US

If You have any questions about this Privacy Policy or Our data practices, please contact Us at:

Catalyst E Pages Pvt. Ltd.
[Address]
India
Email: [Email Address]
Phone: [Phone Number]

This Privacy Policy is effective as of the date You first access or use the Website and will remain in effect until replaced by a new policy.''',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        height: 1.6,
      ),
    );
  }
}


