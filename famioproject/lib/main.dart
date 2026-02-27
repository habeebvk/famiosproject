import 'package:famioproject/views/auth/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'dart:ui'; // Add for PlatformDispatcher
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Add Crashlytics
import 'package:famioproject/firebase_options.dart'; // Add Options
import 'package:famioproject/services/settings_service.dart'; // Add SettingsService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: SettingsService().fontScale,
      builder: (context, fontScale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            // Combine system text scale with our app's font scale
            // textScaleFactor is deprecated but necessary to get the multiplier for TextScaler.linear
            // ignore: deprecated_member_use
            final double systemScale = mediaQuery.textScaleFactor;
            final double finalScale = systemScale * fontScale;

            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(finalScale),
              ),
              child: child!,
            );
          },
          home: SplashScreen(),
        );
      },
    );
  }
}
