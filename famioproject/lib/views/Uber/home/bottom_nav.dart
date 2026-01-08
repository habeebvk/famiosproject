import 'package:famioproject/views/uber/home/home_screen.dart';
import 'package:famioproject/views/uber/profile/uberprofile_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Uber-like modern icon set


class UberBottomNav extends StatefulWidget {
  const UberBottomNav({super.key});

  @override
  State<UberBottomNav> createState() => _UberBottomNavState();
}

class _UberBottomNavState extends State<UberBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    UberMainPage(),
    UberAdminProfilePage(),
   
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
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.shade500,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.home),
                label: 'Home',
              ),
              
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.user),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
