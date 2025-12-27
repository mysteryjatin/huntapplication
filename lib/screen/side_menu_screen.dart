import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hunt_property/screen/add_post_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/home_loan_screen.dart';
import 'package:hunt_property/screen/my_listing_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/advertise_withus_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/articles_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/channel_partner_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/faq_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/financial_calculators_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/legal_advisory_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/nri_center_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/post_requirement_screen.dart';
import 'package:hunt_property/screen/search_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/property_cost_calculator.dart';
import 'package:hunt_property/screen/sidemenu_screen/proptery_news_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/rera_service_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/search_agent_screen.dart';
import 'package:hunt_property/screen/subscription_plans_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/subscriptioncardplan.dart';
import 'package:hunt_property/screen/sidemenu_screen/terms_conditions_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/privacy_policy_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/cancellation_policy_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/shopping_policy_screen.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/profile_service.dart';
import 'package:hunt_property/services/storage_service.dart';

import 'sidemenu_screen/order_history_screen.dart';

class SideMenuScreen extends StatefulWidget {
  final Function(int)? onMenuItemSelected;
  final VoidCallback? onClose;

  const SideMenuScreen({
    super.key,
    this.onMenuItemSelected,
    this.onClose,
  });

  @override
  State<SideMenuScreen> createState() => _SideMenuScreenState();
}

class _SideMenuScreenState extends State<SideMenuScreen> {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check both login status and user ID
      final isLoggedIn = await StorageService.isLoggedIn();
      final userId = await StorageService.getUserId();
      
      if (!isLoggedIn || userId == null || userId.isEmpty || userId == '000000000000000000000000') {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in';
        });
        return;
      }

      final result = await _profileService.getProfile(userId);
      if (result['success']) {
        final profileData = result['data'];
        
        // Save user type to storage if available
        if (profileData is Map) {
          final userType = profileData['user_type']?.toString() ?? 
                          profileData['userType']?.toString();
          if (userType != null && userType.isNotEmpty) {
            await StorageService.saveUserType(userType);
            print('✅ Side Menu - User type saved: $userType');
          }
        }
        
        setState(() {
          _profileData = profileData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(context, _isLoading, _profileData, _errorMessage),

            // Menu Items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Menu Items
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/search.svg',
                      title: 'Search Property',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/search.svg',
                      title: 'Sell or Rent Property',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddPostScreen(),
                          ),
                        );
                        // Navigator.pop(context);
                        // if (onMenuItemSelected != null) {
                        //   onMenuItemSelected!(2);
                        // }
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/search.svg',
                      title: 'Post Your Requirement',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PostRequirementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/search.svg',
                      title: 'My Listings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyListingScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/search.svg',
                      title: 'My Subscriptions',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MySubscriptionCardScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/search.svg',
                      title: 'Order History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    sectionDivider(),
                    const SizedBox(height: 20),

                    // Our Service & Tools Section
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, bottom: 12, top: 4),
                      child: Text(
                        'Our Service & Tools',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/home_loan.svg',
                      title: 'Home Loan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeLoanScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/vastu.svg',
                      title: 'Vastu Calculator',
                      onTap: () {
                        //Navigator.pop(context);
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/agent_search.svg',
                      title: 'Search Agent',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchAgentsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/advertisements.svg',
                      title: 'Advertise with Us',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdvertiseWithUsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/rera.svg',
                      title: 'RERA Service',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReraServicesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/calculator.svg',
                      title: 'Financial Calculators',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FinancialCalculatorsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/calculator.svg',
                      title: 'Property Cost Calculator',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PropertyCostCalculatorScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/search.svg',
                      title: 'Legal Advisory',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LegalAdvisoryScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/search.svg',
                      title: 'Channel Partner / Investors Space',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChannelPartnerScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/property_new.svg',
                      title: 'Property News',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PropertyNewsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/articles.svg',
                      title: 'Articles',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ArticlesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/search.svg',
                      title: 'NRI Center',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NRICenterScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/search.svg',
                      title: 'Customer Care',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FAQScreen(),
                          ),
                        );
                      },
                    ),

                    // Divider before Rate this App
                    // Divider(
                    //   height: 1,
                    //   thickness: 1,
                    //   color: Colors.grey[300],
                    // ),
                    const SizedBox(height: 20),
                    sectionDivider(),
                    const SizedBox(height: 20),
                    // Rate this App - Separate section with black icon
                    _buildMenuItemBlack(
                      context: context,
                      icon: Icons.star,
                      title: 'Rate this App',
                      onTap: () {
                        // Navigator.pop(context);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Social Media Icons - Above policy links
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIcon(
                            svgPath: 'assets/icons/facebook.svg',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _buildSocialIcon(
                            svgPath: 'assets/icons/facebook.svg',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _buildSocialIcon(
                            svgPath: 'assets/icons/facebook.svg',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _buildSocialIcon(
                            svgPath: 'assets/icons/facebook.svg',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _buildSocialIcon(
                            svgPath: 'assets/icons/facebook.svg',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _buildSocialIcon(
                            svgPath: 'assets/icons/facebook.svg',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Policy Links - Below social media icons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPolicyLink('Terms and Conditions', () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TermsConditionsScreen(),
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          _buildPolicyLink('Privacy Policy', () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          _buildPolicyLink('Package Policy', () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ShoppingPolicyScreen(),
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          _buildPolicyLink('Refund and Cancellation Policy',
                              () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CancellationPolicyScreen(),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    bool isLoading,
    Map<String, dynamic>? profileData,
    String? errorMessage,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xfff1f7ff), // light sky-blue background
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Profile info row
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: ClipOval(
                    child: profileData?['profile_picture'] != null
                        ? Image.network(
                            profileData!['profile_picture'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : Image.asset(
                            'assets/images/onboarding1.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Name, email, badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Name
                      Text(
                        profileData?['full_name']?.toString() ??
                            profileData?['name']?.toString() ??
                            'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Email with verified badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profileData?['email']?.toString() ?? 'No email',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (profileData?['email_verified'] == true ||
                              profileData?['is_verified'] == true) ...[
                            const SizedBox(width: 6),
                            SvgPicture.asset(
                              "assets/images/verified.svg",
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Member badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          profileData?['subscription_type']?.toString() ??
                              profileData?['member_type']?.toString() ??
                              'Free member',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 35,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String svgPath, // 👈 ONLY SVG
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            /// SVG ICON
            SvgPicture.asset(
              svgPath,
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                Color(0xFF1A1A1A),
                BlendMode.srcIn,
              ),
            ),

            const SizedBox(width: 16),

            /// TITLE
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon({
    required String svgPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
        ),
        child: Center(
          child: SvgPicture.asset(
            svgPath,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Colors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemBlack({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          decoration: TextDecoration.underline,
          height: 1.4,
        ),
      ),
    );
  }
}

Widget sectionDivider() {
  return Container(
    width: double.infinity,
    height: 10,
    color: const Color(0xFFEDEDED), // light grey
  );
}
