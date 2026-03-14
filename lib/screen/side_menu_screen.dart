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
import 'package:hunt_property/screen/sidemenu_screen/property_cost_calculator.dart';
import 'package:hunt_property/screen/sidemenu_screen/proptery_news_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/rera_service_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/search_agent_screen.dart';
import 'package:hunt_property/screen/search_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/subscriptioncardplan.dart';
import 'package:hunt_property/screen/sidemenu_screen/terms_conditions_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/privacy_policy_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/cancellation_policy_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/shopping_policy_screen.dart';
import 'package:hunt_property/screen/sidemenu_screen/vastu/vastuaiexpert_screen.dart';
import 'package:hunt_property/services/profile_service.dart';
import 'package:hunt_property/services/storage_service.dart';

import 'sidemenu_screen/order_history_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in';
        });
        return;
      }

      final result = await _profileService.getProfile(userId);
      if (result['success']) {
        dynamic profileData = result['data'];

        // -------- PROFILE PICTURE FALLBACK (temp cache) --------
        String? profilePic;
        if (profileData is Map) {
          profilePic = profileData['profile_picture']?.toString() ??
              profileData['profilePicture']?.toString();
        }

        // Agar backend se profile_picture field nahi aa rahi,
        // to Personal Information screen ne jo temp image URL save kiya hai
        // use yahan use kar lo, taaki side menu me bhi updated photo dikh jaye.
        if ((profilePic == null || profilePic.isEmpty) &&
            userId != null &&
            userId.isNotEmpty) {
          final tempPic =
              await StorageService.getTempProfilePicture(userId);
          if (tempPic != null && tempPic.isNotEmpty) {
            if (profileData is Map) {
              profileData = Map<String, dynamic>.from(profileData);
              profileData['profile_picture'] = tempPic;
            }
          }
        } else if (profilePic != null && profilePic.isNotEmpty &&
            userId != null &&
            userId.isNotEmpty) {
          // Backend ne agar pic bhej diya ho to temp cache hata do.
          await StorageService.removeTempProfilePicture(userId);
        }
        
        // Save user type to storage if available
        if (profileData is Map) {
          final userType = profileData['user_type']?.toString() ?? 
                          profileData['userType']?.toString();
          if (userType != null && userType.isNotEmpty) {
            await StorageService.saveUserType(userType);
            print('✅ Side Menu - User type saved: $userType');
          }
        }
        
        if (!mounted) return;
        setState(() {
          _profileData = profileData is Map<String, dynamic>
              ? Map<String, dynamic>.from(profileData)
              : null;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      svgPath: 'assets/icons/sellorrentproperty.svg',
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
                      svgPath: 'assets/icons/postyourrequirement.svg',
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
                      svgPath: 'assets/icons/mylistings.svg',
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
                      svgPath: 'assets/icons/mysubscriptions.svg',
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
                      svgPath: 'assets/icons/orderhistory.svg',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VastuAiExpertScreen(),
                          ),
                        );
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
                      svgPath: 'assets/icons/legaladvisory.svg',
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
                      svgPath: 'assets/icons/channelpartner.svg',
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
                      svgPath: 'assets/icons/nricenter.svg',
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
                      svgPath: 'assets/icons/customercare.svg',
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
                            url: 'https://www.facebook.com/LetsHuntProperty/',
                          ),
                          const SizedBox(width: 12),
                          _buildSocialIcon(
                            svgPath: 'assets/icons/youtube.svg',
                            url: 'https://x.com/thehuntproperty?s=21',
                          ),
                          const SizedBox(width: 12),
                          _buildSocialIcon(
                            svgPath: 'assets/icons/linklnd.svg',
                            url:
                                'https://www.linkedin.com/company/hunt-propert/?viewAsMember=true',
                          ),
                          const SizedBox(width: 12),
                          _buildSocialIcon(
                            svgPath: 'assets/icons/instagram.svg',
                            url: 'https://www.instagram.com/huntpropertyindia/',
                          ),
                          const SizedBox(width: 12),
                          _buildSocialIcon(
                            svgPath: 'assets/icons/whatsapp.svg',
                            url: 'https://wa.me/',
                          ),
                          const SizedBox(width: 12),
                          _buildSocialIcon(
                            svgPath: 'assets/icons/twitter.svg',
                            url: 'https://x.com/thehuntproperty?s=21',
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
    required String url,
  }) {
    return GestureDetector(
      onTap: () async {
        await launchUrlString(url);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
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

/// Custom curved bottom navigation bar inspired by provided design screenshot.
///
/// Usage example (wrap inside any `Scaffold`):
/// ```dart
/// Scaffold(
///   body: _pages[_currentIndex],
///   bottomNavigationBar: CurvedBottomNavBar(
///     currentIndex: _currentIndex,
///     onTap: (index) => setState(() => _currentIndex = index),
///   ),
/// );
/// ```
class CurvedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CurvedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CurvedBottomNavBar> createState() => _CurvedBottomNavBarState();
}

class _CurvedBottomNavBarState extends State<CurvedBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _positionAnimation;
  late double _currentIndexAsDouble;

  @override
  void initState() {
    super.initState();
    _currentIndexAsDouble = widget.currentIndex.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _elevationAnimation = curve;
    _positionAnimation = Tween<double>(
      begin: _currentIndexAsDouble,
      end: _currentIndexAsDouble,
    ).animate(curve);
    _controller.forward();
  }

  @override
  void didUpdateWidget(CurvedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      final newIndex = widget.currentIndex.toDouble();
      _positionAnimation = Tween<double>(
        begin: _positionAnimation.value,
        end: newIndex,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOutCubic,
        ),
      );
      _currentIndexAsDouble = newIndex;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(Icons.home_filled, 'Home'),
      _NavItemData(Icons.search, 'Search'),
      _NavItemData(Icons.add_circle_outline, 'Add'),
      _NavItemData(Icons.favorite_border, 'Shortlist'),
      _NavItemData(Icons.person_outline, 'Profile'),
    ];

    final itemCount = items.length.clamp(1, items.length);
    final selectedPosition =
        (_positionAnimation.value + 0.5) / itemCount; // 0..1 across width

    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Green background with small wave under selected icon
          Positioned.fill(
            child: CustomPaint(
              painter: _BubbleNavPainter(
                color: const Color(0xFF00D08F),
                position: selectedPosition.clamp(0.0, 1.0),
              ),
            ),
          ),

          // Icons & labels row
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = index == widget.currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onTap(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _elevationAnimation,
                            builder: (context, child) {
                              final elevation = isSelected
                                  ? -22.0 * _elevationAnimation.value
                                  : 0.0;

                              Widget iconWidget;
                              if (isSelected) {
                                iconWidget = Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF00D08F),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    size: 24,
                                    color: Colors.black,
                                  ),
                                );
                              } else {
                                iconWidget = Icon(
                                  item.icon,
                                  size: 24,
                                  color: Colors.black,
                                );
                              }

                              return Transform.translate(
                                offset: Offset(0, elevation),
                                child: iconWidget,
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  _NavItemData(this.icon, this.label);
}

class _BubbleNavPainter extends CustomPainter {
  final Color color;
  final double position; // 0..1 across the width

  _BubbleNavPainter({
    required this.color,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Flat top bar with a small "valley" cut around selected icon
    final baseTop = 0.0;
    final valleyDepth = 18.0;
    final valleyWidth = 90.0;
    final centerX = size.width * position;
    final leftValley = (centerX - valleyWidth / 2).clamp(0.0, size.width);
    final rightValley = (centerX + valleyWidth / 2).clamp(0.0, size.width);

    final path = Path();
    path.moveTo(0, baseTop);
    path.lineTo(leftValley, baseTop);

    // Valley dipping down beneath the selected icon
    final controlDown1 =
        Offset(centerX - valleyWidth / 4, baseTop + valleyDepth);
    final controlDown2 =
        Offset(centerX + valleyWidth / 4, baseTop + valleyDepth);

    path.quadraticBezierTo(
      controlDown1.dx,
      controlDown1.dy,
      centerX,
      baseTop + valleyDepth,
    );
    path.quadraticBezierTo(
      controlDown2.dx,
      controlDown2.dy,
      rightValley,
      baseTop,
    );

    path.lineTo(size.width, baseTop);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleNavPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.position != position;
  }
}
