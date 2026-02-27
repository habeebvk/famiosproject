import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:famioproject/views/auth/login_screen.dart';

import 'package:famioproject/views/hospital/home/bottom_nav.dart';
import 'package:famioproject/views/grocery/home/bottom_nav.dart';
import 'package:famioproject/views/fooddelivery/home/bottom_nav.dart';
import 'package:famioproject/views/cleaning/cleaninghome_screen.dart';
import 'package:famioproject/views/uber/home/bottom_nav.dart';
import 'package:famioproject/views/user/home/bottom_navigation.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for a minimum time to show the logo (optional, e.g., 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final role = doc.data()!['role'] as String?;
          if (role != null) {
            if (mounted) {
              _navigateToDashboard(context, role);
            }
            return;
          }
        }
      } catch (e) {
        debugPrint("Auto-login error: $e");
        // Fallback to login on error
      }
    }

    // specific check for mounted before using context
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateToDashboard(BuildContext context, String role) {
    Widget destination;

    switch (role) {
      case 'Hospital':
        destination = const HospitalBottomNav();
        break;
      case 'Grocery':
        destination = GroceryBottomnav();
        break;
      case 'Food Delivery':
        destination = const FoodBottomnav();
        break;
      case 'Cleaning':
        destination = const AdminDashboard();
        break;
      case 'Uber':
        destination = const UberBottomNav();
        break;
      case 'Patient':
      default:
        destination = const MainScreen();
    }

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your logo or image
            Image.asset('assets/famio_logo.png', height: 120),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Show loading while checking
          ],
        ),
      ),
    );
  }
}
