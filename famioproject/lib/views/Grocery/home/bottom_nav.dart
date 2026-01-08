
import 'package:famioproject/views/grocery/home/grocery_screen.dart';
import 'package:famioproject/views/grocery/products/products_screen.dart';
import 'package:famioproject/views/grocery/profile/profile_screen.dart';
import 'package:flutter/material.dart';


class GroceryBottomnav extends StatefulWidget {
  const GroceryBottomnav({super.key});

  @override
  State<GroceryBottomnav> createState() => _GroceryBottomnavState();
}

class _GroceryBottomnavState extends State<GroceryBottomnav> {
  int _currentIndex = 0;

  final List<Widget> _screens =  [
    HomePage(), // ✅ Use here
    ProductListPage(),
   GroceryProfileScreen(),
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
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items:  [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'products'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}