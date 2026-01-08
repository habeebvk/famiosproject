import 'package:famioproject/views/hospital/Appointments/appointment_screen.dart';
import 'package:famioproject/views/hospital/Hospitals/hospitalpge_screen.dart';
import 'package:famioproject/views/hospital/Patients/patients_screen.dart';
import 'package:flutter/material.dart';
// Import DoctorManagementPage with alias if needed
import 'package:famioproject/views/hospital/Doctors/doctorpage_screen.dart';

class HospitalOptionsPage extends StatelessWidget {
  const HospitalOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_OptionItem> options = [
      _OptionItem(
        title: 'Doctors',
        icon: Icons.local_hospital_rounded,
        color: Colors.blueAccent,
        destination: const DoctorManagementPage(),
      ),
      _OptionItem(
        title: 'Patients',
        icon: Icons.people_alt_rounded,
        color: Colors.green,
        destination: const PatientManagementPage(),
      ),
      _OptionItem(
        title: 'Appointments',
        icon: Icons.calendar_today_rounded,
        color: Colors.orangeAccent,
        destination: const AppointmentsPage(),
      ),
      _OptionItem(
        title: 'Hospitals',
        icon: Icons.apartment_rounded,
        color: Colors.purpleAccent,
        destination: const HospitalManagementPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Options',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView.builder(
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => option.destination),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: option.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: option.color.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: option.color.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: option.color.withOpacity(0.15),
                      radius: 28,
                      child: Icon(option.icon, color: option.color, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: option.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OptionItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget destination; // declare destination field with proper type

  const _OptionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.destination,
  });
}