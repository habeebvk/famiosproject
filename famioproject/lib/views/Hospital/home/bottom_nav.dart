import 'package:famioproject/views/Hospital/Appointments/appointment_screen.dart';
import 'package:famioproject/views/Hospital/Patients/patients_screen.dart';
import 'package:famioproject/views/hospital/home/hospitalhome_screen.dart';
import 'package:famioproject/views/hospital/options/options_screen.dart';
import 'package:famioproject/views/hospital/profile/hospitalprofile_screen.dart';

import 'package:flutter/material.dart';

class HospitalBottomNav extends StatefulWidget {
  const HospitalBottomNav({super.key});

  @override
  State<HospitalBottomNav> createState() => _HospitalBottomNavState();
}

class _HospitalBottomNavState extends State<HospitalBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens =  [
    Hospitaladmin(),
   AppointmentsPage(),
    //  HospitalOptionsPage(),
     PatientManagementPage(),
     HospitalAdminProfilePage(),    
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
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.teal.shade700,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
               BottomNavigationBarItem(
                icon: Icon(Icons.date_range),
                label: 'Appoinments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Patients',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
