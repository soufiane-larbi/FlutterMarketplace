import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jibeex/my_theme.dart';
import 'package:jibeex/screens/splash.dart';
import 'package:shared_value/shared_value.dart';
import 'package:jibeex/helpers/shared_value_helper.dart';
import 'dart:async';
import 'package:jibeex/repositories/auth_repository.dart';
import 'app_config.dart';
import 'package:jibeex/services/push_notification_service.dart';
import 'package:one_context/one_context.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:ui';
import 'package:jibeex/app_config.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  fetch_user() async {
    var userByTokenResponse = await AuthRepository().getUserByTokenResponse();
    if (userByTokenResponse.result == true) {
      is_logged_in.value = true;
      user_id.value = userByTokenResponse.id;
      user_name.value = userByTokenResponse.name;
      user_email.value = userByTokenResponse.email;
      user_phone.value = userByTokenResponse.phone;
      avatar_original.value = userByTokenResponse.avatar_original;
    }
  }

  access_token.load().whenComplete(() {
    fetch_user();
  });

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.blueGrey[800],
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(
    SharedValue.wrapApp(
      MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  static FirebaseAnalytics analytics;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;
  @override
  void initState() {
    super.initState();
    MyApp.analytics = FirebaseAnalytics();
    Future.delayed(Duration(milliseconds: 100), () async {
      PushNotificationService().initialise();
    });
  }

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      builder: OneContext().builder,
      navigatorKey: OneContext().navigator.key,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: MyApp.analytics)
      ],
      title: AppConfig.app_name,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: MyTheme.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        accentColor: MyTheme.accent_color,
        textTheme: GoogleFonts.sourceSansProTextTheme(textTheme).copyWith(
          bodyText1: GoogleFonts.sourceSansPro(textStyle: textTheme.bodyText1),
          bodyText2: GoogleFonts.sourceSansPro(
              textStyle: textTheme.bodyText2, fontSize: 12),
        ),
      ),
      home: Splash(),
      //home: Main(),
    );
  }
}
