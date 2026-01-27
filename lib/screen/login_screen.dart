import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hunt_property/cubit/auth_cubit.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/services/auth_service.dart';
import 'package:hunt_property/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _input = TextEditingController();
  final FocusNode _phoneFocus = FocusNode(debugLabel: 'phone_input');
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _input.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return '+91$cleaned';
  }

  Future<void> _signInWithGoogle() async {
    if (_isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _isGoogleLoading = false);
        return; // user cancelled
      }

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user;

      // Get user info from Google account
      final email = user?.email ?? account.email ?? '';
      final name = user?.displayName ?? account.displayName ?? 'User';
      final photoUrl = user?.photoURL ?? account.photoUrl;

      if (email.isEmpty) {
        throw Exception('Email not available from Google account');
      }

      // Find or create user in backend database
      final authService = AuthService();
      final result = await authService.googleSignIn(
        email: email,
        name: name,
        photoUrl: photoUrl,
      );

      if (!result['success']) {
        throw Exception(result['error'] ?? 'Failed to authenticate with backend');
      }

      final userData = result['data'];
      final userId = userData['user_id']?.toString();
      final userType = userData['user_type']?.toString() ?? 'buyer';
      final phone = userData['phone']?.toString() ?? email;

      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not received from backend');
      }

      // Save user data to storage
      await StorageService.saveUserId(userId);
      await StorageService.saveUserPhone(phone);
      await StorageService.saveUserType(userType);
      await StorageService.setLoggedIn(true);

      print('✅ Google Sign-In: User authenticated successfully');
      print('   User ID: $userId');
      print('   Email: $email');
      print('   Name: $name');
      print('   User Type: $userType');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in successful'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
      current is OtpRequested || current is AuthError,
      listener: (context, state) {
        if (state is OtpRequested) {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.pushNamed(
            context,
            '/otp',
            arguments: state.phone,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        /// 🔑 Let Flutter handle keyboard naturally
        resizeToAvoidBottomInset: true,

        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.manual,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                /// LOGO / GIF
                SizedBox(
                  height: 220,
                  child: Image.asset(
                    'assets/images/Huntproperty logo-gif.gif',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Welcome',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Log in to access your account',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 36),

                /// ================= FORM =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// PHONE INPUT (KEYBOARD STABLE)
                      TextField(
                        controller: _input,
                        focusNode: _phoneFocus,
                        autofocus: false,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Mobile Number (10 digits)',
                          hintStyle: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF2F9FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          counterText: '',
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// NEXT BUTTON
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                FocusManager
                                    .instance.primaryFocus
                                    ?.unfocus();

                                final phone = _input.text.trim();
                                if (phone.length != 10) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Enter valid 10 digit mobile number'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                context
                                    .read<AuthCubit>()
                                    .checkPhone(
                                  _formatPhoneNumber(phone),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                AppColors.primaryColor,
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                              )
                                  : const Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      /// SOCIAL LOGIN
                      _SocialButton(
                        icon: 'assets/icons/google icon.svg',
                        label: 'Sign in with Google',
                        loading: _isGoogleLoading,
                        onTap: _signInWithGoogle,
                      ),

                      const SizedBox(height: 14),

                      _SocialButton(
                        icon: 'assets/icons/appleicon.svg',
                        label: 'Sign in with Apple',
                        onTap: () {},
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 13),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textDark),
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              SvgPicture.asset(icon, width: 22, height: 22),
              const SizedBox(width: 10),
            ],
            Text(
              loading ? 'Signing in...' : label,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
