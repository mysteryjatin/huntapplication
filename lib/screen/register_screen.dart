import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/cubit/auth_cubit.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  String _userType = 'user'; // Default user type
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    // Get phone number from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          _phone.text = args;
        });
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (route) => false);
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
        appBar: AppBar(
          title: const Text('Create Account'),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2FED9A),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Please fill in your details',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),

                Text('Sign Up', style: theme.textTheme.titleMedium),
                const SizedBox(height: 30),

                // FULL NAME
                _inputField(
                  hint: "Full Name",
                  controller: _name,
                ),
                const SizedBox(height: 12),

                // EMAIL
                _inputField(
                  hint: "Email",
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                // PHONE
                _inputField(
                  hint: "Mobile Number",
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  enabled: false, // Phone is pre-filled and disabled
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 20),
                Text('User Type', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _choice('User', _userType == 'user',
                        () => setState(() => _userType = 'user')),
                    const SizedBox(width: 12),
                    _choice('Agent', _userType == 'agent',
                        () => setState(() => _userType = 'agent')),
                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      activeColor: AppColors.primaryColor,
                      onChanged: (v) =>
                          setState(() => _acceptTerms = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to our Terms & Conditions and Privacy Policy',
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 40),

                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: (_acceptTerms && !isLoading)
                          ? () {
                              if (_name.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter your name'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (_email.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter your email'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              // Validate email format
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(_email.text.trim())) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a valid email address'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (_phone.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Phone number is required'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              context.read<AuthCubit>().signup(
                                    name: _name.text.trim(),
                                    email: _email.text.trim(),
                                    phone: _phone.text.trim(),
                                    userType: _userType,
                                    termsAccepted: _acceptTerms,
                                  );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black),
                              ),
                            )
                          else
                            const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                // Add responsive bottom padding for system navigation
                SizedBox(height: 40 + MediaQuery.of(context).viewPadding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 CUSTOM INPUT FIELD
  Widget _inputField({
    required String hint,
    TextEditingController? controller,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? const Color(0xFFF2F9FF) : Colors.grey[200],
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFDFE1E4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.5,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[400]!,
            width: 1.5,
          ),
        ),

        suffixIcon: suffix,
      ),
    );
  }

  // 🔥 CHOICE BUTTON
  Widget _choice(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
