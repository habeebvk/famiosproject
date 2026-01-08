
import 'package:famioproject/views/user/hospital/doctor_screen.dart';
import 'package:flutter/material.dart';

class Hospitalscreen extends StatelessWidget {
  const Hospitalscreen({super.key});

  // Dummy hospital data
  final List<Hospital> hospitals = const [
    Hospital(name: "Vinayaka Hospital", place: "Sulthan Bathery"),
    Hospital(name: "Kunnamkulam Medical Center", place: "Kunnamkulam"),
    Hospital(name: "WIMS Hospital", place: "Meppadi"),
    Hospital(name: "Assumption Hospital", place: "Sulthan Bathery"),
    Hospital(name: "Victory Hospital", place: "Sulthan Bathery"),
    Hospital(name: "Metro Health Services", place: "Meenangadi"),
    Hospital(name: "Iqura Hospital", place: "Sulthan Bathery"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Light background
    
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];
          return HospitalCard(hospital: hospital);
        },
      ),
    );
  }
}

// ----------------------------
// Custom Hospital Card Widget
// ----------------------------
class HospitalCard extends StatelessWidget {
  final Hospital hospital;

  const HospitalCard({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){

        Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorListPage()));
      },
      child: Card(
        elevation: 6,
        shadowColor: Colors.teal.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_hospital, color: Colors.teal, size: 30),
              ),
              const SizedBox(width: 16),
      
              // Hospital Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          hospital.place,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------
// Hospital Model
// ----------------------------
class Hospital {
  final String name;
  final String place;

  const Hospital({
    required this.name,
    required this.place,
  });
}
