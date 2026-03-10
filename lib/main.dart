import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sms_autofill/sms_autofill.dart';
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
import 'firebase_messaging_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Background handler for FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Local notifications init (Android)
  const AndroidInitializationSettings initAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final route = response.payload;
      if (route != null && route.isNotEmpty) {
        navigatorKey.currentState?.pushNamed(route);
      }
    },
  );

  // Android notification channel for FCM
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel',
    'Default Notifications',
    description: 'Default channel for FCM notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Notification permissions (Android 13+ and iOS)
  await _requestNotificationPermission();

  // TEMP: Print SMS app signature for OTP auto-fill setup
  try {
    final sig = await SmsAutoFill().getAppSignature;
    print('📌 APP SIGNATURE (give this to backend for SMS template): $sig');
  } catch (e) {
    print('❌ Failed to get app signature: $e');
  }

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    // Verify API key is loaded (for debugging - remove in production if needed)
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      print('✅ Environment variables loaded successfully');
      print('✅ OPENAI_API_KEY found in .env (length: ${apiKey.length})');
    } else {
      print('⚠️ WARNING: OPENAI_API_KEY not found in .env file');
      print('⚠️ Please create .env file with OPENAI_API_KEY=your_key_here');
    }
  } catch (e) {
    print('❌ ERROR: Failed to load .env file: $e');
    print('❌ Please make sure .env file exists in the root directory');
    print('❌ You can copy .env.example to .env and add your API key');
  }

  // Pre-initialize SharedPreferences to avoid platform channel errors
  // Add a small delay to ensure platform channels are ready
  await Future.delayed(const Duration(milliseconds: 100));

  try {
    await StorageService.initialize(forceRefresh: true);
  } catch (e) {
    print('Warning: Failed to pre-initialize SharedPreferences: $e');
    // Continue anyway - it will retry when needed
  }

  // Device FCM token (send to your backend)
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('✅ FCM TOKEN: $token');
    }
  } catch (e) {
    print('❌ Failed to get FCM token: $e');
  }

  runApp(const MyApp());
}

Future<void> _requestNotificationPermission() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _listenForegroundMessages();
    _setupInteractedMessage();
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = notification?.android;

      if (notification != null && android != null) {
        final data = message.data;

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default Notifications',
              channelDescription: 'Default channel for FCM notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: data['route'],
        );
      }
    });
  }

  Future<void> _setupInteractedMessage() async {
    // App background में था और user ने notification tap किया
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

    // App completely बंद था और notification से open हुआ
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageNavigation(initialMessage);
    }
  }

  void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;
    final route = data['route'] ?? '/home';

    if (!mounted) return;
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthService()),
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
          '/subscription-plans': (_) =>
              const SubscriptionPlansScreen(),
        },
      ),
    );
  }
}

