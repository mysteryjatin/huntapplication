import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hunt_property/screen/change_password_screen.dart';
import 'package:hunt_property/screen/my_listing_screen.dart';
import 'package:hunt_property/screen/notification_preference_screen.dart';
import 'package:hunt_property/screen/personal_information_screen.dart';
import 'package:hunt_property/screen/subscription_plans_screen.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/services/profile_service.dart';
import 'package:hunt_property/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const ProfileScreen({super.key, this.onBackPressed});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      final token = await StorageService.getToken();
      
      // Debug: Print all auth info to verify
      print('🔍 Profile Screen - Is Logged In: $isLoggedIn');
      print('🔍 Profile Screen - User ID: $userId');
      print('🔍 Profile Screen - Token exists: ${token != null && token.isNotEmpty}');
      
      if (!isLoggedIn || userId == null || userId.isEmpty || userId == '000000000000000000000000') {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in';
        });
        print('⚠️ Profile Screen - User not logged in. isLoggedIn: $isLoggedIn, userId: $userId');
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
            print('✅ Profile Screen - User type saved: $userType');
          }
        }
        
        setState(() {
          _profileData = profileData;
          _isLoading = false;
        });
        print('✅ Profile Screen - Profile loaded successfully');
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load profile';
          _isLoading = false;
        });
        print('❌ Profile Screen - Failed to load profile: ${result['error']}');
      }
    } catch (e) {
      print('❌ Profile Screen Error: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    // Clear all stored data to end the session
    await StorageService.clearAll();
    print('✅ User logged out - Session cleared');
    
    // Navigate to login screen
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Green Header Section
          _buildHeaderSection(),
          
          // Menu Items Section
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context: context,
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PersonalInformationScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.home_outlined,
                      title: 'My Listing',
                      onTap: () {
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
                      icon: Icons.card_membership_outlined,
                      title: 'Subscription Plan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionPlansScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.notifications_outlined,
                      title: 'Notification Preference',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationPreferenceScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () {
                        // Show logout confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Are you sure you want to logout?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Navigator.pop(context),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            side: BorderSide(color: Colors.grey.shade300),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'No',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _logout();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Logged out successfully!')),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2FED9A),
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Yes',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      isLogout: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2FED9A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Profile Title
              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Profile Info Row
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
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
                  children: [
                    // Profile Picture
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: _profileData?['profile_picture'] != null
                            ? Image.network(
                                _profileData!['profile_picture'],
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
                    
                    // Name, Email, Badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Name
                          Text(
                            _profileData?['full_name']?.toString() ?? 
                            _profileData?['name']?.toString() ?? 
                            'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Email with verified badge
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _profileData?['email']?.toString() ?? 
                                  'No email',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_profileData?['email_verified'] == true || 
                                  _profileData?['is_verified'] == true)
                                const SizedBox(width: 6),
                              if (_profileData?['email_verified'] == true || 
                                  _profileData?['is_verified'] == true)
                                SvgPicture.asset(
                                  "assets/images/verified.svg",
                                  width: 20,
                                  height: 20,
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Member Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x331A1A1A), // #1A1A1A33
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _profileData?['subscription_type']?.toString() ?? 
                              _profileData?['member_type']?.toString() ?? 
                              'Free member',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.7),
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
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(
        Icons.person,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLogout 
                    ? Colors.red.shade50 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isLogout ? Colors.red : Colors.black87,
                size: 22,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.red : Colors.black87,
                ),
              ),
            ),
            
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isLogout ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

