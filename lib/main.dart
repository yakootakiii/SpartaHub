import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/authentication_screen.dart';
import 'screens/main_screen.dart';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _showNotification(message);
}

// Show notification locally (foreground)
void _showNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel',
    'General Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await _localNotifications.show(
    notification.hashCode,
    notification.title,
    notification.body,
    details,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );
  await _localNotifications.initialize(initSettings);

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

    if (user != null) {
      await _setupPushNotifications(user.uid);
    }
  }

  Future<void> _setupPushNotifications(String userId) async {
    if (kIsWeb) return;

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    if (!isAndroid && !isIOS) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    if (isIOS) {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint("Notification permission denied.");
        return;
      }
      // Skip APNS token on simulator
      if (!await _isSimulator()) {
        await messaging.getAPNSToken();
      }
    }

    // Android & iOS: get FCM token
    final token = await messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
      debugPrint('FCM Token saved: $token');
    }

    // Foreground messages: manually show notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Optionally handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked: ${message.data}');
    });
  }

  Future<bool> _isSimulator() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    return !kIsWeb; // simple check for now
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
