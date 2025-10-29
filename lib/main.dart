import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/authentication_screen.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final currentUser = FirebaseAuth.instance.currentUser;

  runApp(
    SpartaHubApp(
      hasSeenOnboarding: hasSeenOnboarding,
      isLoggedIn: currentUser != null,
    ),
  );
}

class SpartaHubApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;

  const SpartaHubApp({
    super.key,
    this.hasSeenOnboarding = false,
    this.isLoggedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget startScreen;

    // ✅ Decide which screen to show first
    if (!hasSeenOnboarding) {
      startScreen = const OnboardingScreen();
    } else if (isLoggedIn) {
      startScreen = const MainScreen();
    } else {
      startScreen = const AuthenticationScreen();
    }

    return MaterialApp(
      title: 'SpartaHub',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: startScreen,
      debugShowCheckedModeBanner: false,
    );
  }
}
