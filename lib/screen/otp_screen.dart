import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/cubit/auth_cubit.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _codes =
      List.generate(6, (_) => TextEditingController());

  Timer? _timer;
  int _seconds = 30;
  String? _phoneNumber;
  String? _displayOtp; // OTP to display for testing
  bool _isLogin = false; // Track if this is login or signup flow

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Get phone number from arguments and check current state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          _phoneNumber = args;
        });
      }
      
      // Check current state for OTP
      final currentState = context.read<AuthCubit>().state;
      if (currentState is OtpRequested) {
        print('Found OtpRequested state on init. OTP: ${currentState.otp}, isLogin: ${currentState.isLogin}');
        setState(() {
          _displayOtp = currentState.otp;
          _isLogin = currentState.isLogin;
          // Auto-fill OTP if available and is 6 digits
          if (currentState.otp != null && currentState.otp!.length == 6) {
            for (int i = 0; i < 6 && i < _codes.length; i++) {
              _codes[i].text = currentState.otp![i];
            }
          }
        });
      }
    });
  }

  void _startTimer() {
    _seconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _codes) {
      c.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _verify() {
    if (_phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final otp = _codes.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthCubit>().verifyOtp(_phoneNumber!, otp, isLogin: _isLogin);
  }

  void _resendOtp() {
    if (_phoneNumber != null) {
      if (_isLogin) {
        context.read<AuthCubit>().loginRequestOtp(_phoneNumber!);
      } else {
        context.read<AuthCubit>().requestOtp(_phoneNumber!);
      }
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          if (state.phoneExists) {
            // Phone exists, navigate to home
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (route) => false);
          } else {
            // Phone doesn't exist, navigate to signup
            Navigator.of(context).pushReplacementNamed('/register',
                arguments: _phoneNumber);
          }
        } else if (state is SignupRequired) {
          Navigator.of(context).pushReplacementNamed('/register',
              arguments: state.phone);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is OtpRequested) {
          // Always store OTP for display (even if null, we'll show a message)
          print('OtpRequested state received. OTP: ${state.otp}, isLogin: ${state.isLogin}');
          setState(() {
            _displayOtp = state.otp;
            _isLogin = state.isLogin;
            print('Updated _displayOtp to: $_displayOtp, _isLogin: $_isLogin');
            // Auto-fill OTP if available and is 6 digits
            if (state.otp != null && state.otp!.length == 6) {
              print('Auto-filling OTP: ${state.otp}');
              for (int i = 0; i < 6 && i < _codes.length; i++) {
                _codes[i].text = state.otp![i];
              }
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.otp != null 
                  ? 'OTP sent successfully: ${state.otp}' 
                  : 'OTP sent successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        // Update OTP display when state changes
        if (state is OtpRequested && state.otp != null && state.otp != _displayOtp) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _displayOtp = state.otp;
              _isLogin = state.isLogin;
              // Auto-fill OTP if available and is 6 digits
              if (state.otp!.length == 6) {
                for (int i = 0; i < 6 && i < _codes.length; i++) {
                  _codes[i].text = state.otp![i];
                }
              }
            });
          });
        }
        
        return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                Text('Almost there', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 6),

                Text(
                  _phoneNumber != null
                      ? 'Please enter the 6-digit code sent to your mobile no: $_phoneNumber for verification.'
                      : 'Please enter the 6-digit code sent to your mobile number for verification.',
                  style: theme.textTheme.bodyMedium,
                ),

                // Display OTP for testing (always show, even if null)
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _displayOtp != null 
                        ? Colors.yellow.shade100 
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _displayOtp != null ? Colors.orange : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _displayOtp != null 
                            ? Icons.info_outline 
                            : Icons.warning_amber_rounded,
                        color: _displayOtp != null ? Colors.orange : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _displayOtp != null 
                              ? 'OTP: $_displayOtp'
                              : 'OTP not found. Check logs.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _displayOtp != null ? Colors.orange : Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 100),

              /// OTP BOXES — FIXED, NO OVERLAP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                      (i) => _OtpBox(controller: _codes[i]),
                ),
              ),

              const SizedBox(height: 80),

              /// VERIFY BUTTON
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _verify,
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
                              'Verify',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          if (!isLoading) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              /// RESEND SECTION
              Center(
                child: Column(
                  children: [
                    Text(
                      "Didn't receive any code? Resend Again",
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _seconds == 0
                          ? 'Request new code now'
                          : 'Request new code in 00:${_seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: AppColors.redcolor),
                    ),
                    TextButton(
                      onPressed: _seconds == 0 ? _resendOtp : null,
                      child: const Text('Resend code'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              /// BACK BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FloatingActionButton(
                      mini: false,
                      shape: const CircleBorder(),
                      backgroundColor: AppColors.primaryColor,
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              
              // Add responsive bottom padding for system navigation
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
            ],
          ),
        ),
      ),
      );
      },
    );
  }
}

/// PERFECT OTP BOX (no overflow)
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  const _OtpBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.greenAccent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (v) {
          if (v.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
