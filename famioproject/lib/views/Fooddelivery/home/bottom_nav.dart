import 'package:famioproject/views/Fooddelivery/Products/foodproducts_screen.dart';
import 'package:famioproject/views/Fooddelivery/home/home_screen.dart';
import 'package:famioproject/views/Fooddelivery/profile/profiles_screen.dart';
import 'package:flutter/material.dart';

class FoodBottomnav extends StatefulWidget {
  const FoodBottomnav({super.key});

  @override
  State<FoodBottomnav> createState() => _FoodBottomnavState();
}

class _FoodBottomnavState extends State<FoodBottomnav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
     FoodRequestDashboard(), // ✅ No parameters now
    FoodProductPage(),
    foodProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Products'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
