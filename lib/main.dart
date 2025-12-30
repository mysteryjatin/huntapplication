import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/auth_cubit.dart';
import 'package:hunt_property/screen/add_post_screen.dart';
import 'package:hunt_property/screen/add_post_step2_screen.dart';
import 'package:hunt_property/screen/add_post_step3_screen.dart';
import 'package:hunt_property/screen/add_post_step4_screen.dart';
import 'package:hunt_property/screen/buy_properties_screen.dart';
import 'package:hunt_property/screen/home_screen.dart';
import 'package:hunt_property/screen/login_screen.dart';
import 'package:hunt_property/screen/onboarding_screen.dart';
import 'package:hunt_property/screen/otp_screen.dart';
import 'package:hunt_property/screen/plan_activation_screen.dart';
import 'package:hunt_property/screen/profile_screen.dart';
import 'package:hunt_property/screen/register_screen.dart';
import 'package:hunt_property/screen/rent_properties_screen.dart';
import 'package:hunt_property/screen/search_screen.dart';
import 'package:hunt_property/screen/shortlist_screen.dart';
import 'package:hunt_property/screen/spin_popup_screen.dart';
import 'package:hunt_property/screen/spin_result_screen.dart';
import 'package:hunt_property/screen/splash_screen.dart';
import 'package:hunt_property/screen/subscription_plans_screen.dart';
import 'package:hunt_property/services/auth_service.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/models/property_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-initialize SharedPreferences to avoid platform channel errors
  // Add a small delay to ensure platform channels are ready
  await Future.delayed(const Duration(milliseconds: 100));
  
  try {
    await StorageService.initialize(forceRefresh: true);
  } catch (e) {
    print('Warning: Failed to pre-initialize SharedPreferences: $e');
    // Continue anyway - it will retry when needed
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthService()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hunt Property',
        theme: buildAppTheme(),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/otp': (_) => const OtpVerificationScreen(),
          '/register': (_) => const CreateAccountScreen(),
          '/spin-popup': (_) => const SpinPopupScreen(),
          '/spin-result': (_) => const SpinResultScreen(),
          '/plan-activation': (_) => const PlanActivationScreen(),
          '/home': (_) => const HomeScreen(),
          '/search': (_) => const SearchScreen(),
          '/add-post': (_) => const AddPostScreen(),
          // For step 2–4 we must provide a PropertyDraft instance.
          // These named routes are mainly fallbacks; normal flow passes
          // the draft via Navigator.push with MaterialPageRoute.
          '/add-post-step2': (_) => AddPostStep2Screen(draft: PropertyDraft()),
          '/add-post-step3': (_) => AddPostStep3Screen(draft: PropertyDraft()),
          '/add-post-step4': (_) => AddPostStep4Screen(draft: PropertyDraft()),
          '/shortlist': (_) => const ShortlistScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/rent-properties': (_) => const RentPropertiesScreen(),
          '/buy-properties': (_) => const BuyPropertiesScreen(),
          '/subscription-plans': (_) => const SubscriptionPlansScreen(),
        },
      ),
    );
  }
}
 
