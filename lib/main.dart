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

  runApp(const SpartaHubApp());
}

class SpartaHubApp extends StatefulWidget {
  const SpartaHubApp({super.key});

  @override
  State<SpartaHubApp> createState() => _SpartaHubAppState();
}

class _SpartaHubAppState extends State<SpartaHubApp> {
  bool? _hasSeenOnboarding;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStartupState();
  }

  Future<void> _loadStartupState() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_onboarding') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _hasSeenOnboarding = hasSeen;
      _currentUser = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    Widget startScreen;
    if (!_hasSeenOnboarding!) {
      startScreen = const OnboardingScreen();
    } else if (_currentUser != null) {
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
