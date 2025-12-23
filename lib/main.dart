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
import 'package:hunt_property/screen/profile_screen.dart';
import 'package:hunt_property/screen/register_screen.dart';
import 'package:hunt_property/screen/rent_properties_screen.dart';
import 'package:hunt_property/screen/search_screen.dart';
import 'package:hunt_property/screen/shortlist_screen.dart';
import 'package:hunt_property/screen/splash_screen.dart';
import 'package:hunt_property/services/auth_service.dart';
import 'package:hunt_property/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          '/home': (_) => const HomeScreen(),
          '/search': (_) => const SearchScreen(),
          '/add-post': (_) => const AddPostScreen(),
          '/add-post-step2': (_) => const AddPostStep2Screen(),
          '/add-post-step3': (_) => const AddPostStep3Screen(),
          '/add-post-step4': (_) => const AddPostStep4Screen(),
          '/shortlist': (_) => const ShortlistScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/rent-properties': (_) => const RentPropertiesScreen(),
          '/buy-properties': (_) => const BuyPropertiesScreen(),
        },
      ),
    );
  }
}
 
