import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// Import your destination pages
import 'package:famioproject/views/cleaning/profile/profile_screen.dart';
import 'package:famioproject/views/cleaning/requests/accept_screen.dart';
import 'package:famioproject/views/cleaning/services/bookings/booking_screen.dart';
import 'package:famioproject/views/cleaning/services/servicelist_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_AdminFeature> features = [
      _AdminFeature(
        title: 'Services',
        icon: Icons.cleaning_services_outlined,
        color: Colors.teal,
        destination: ServiceAddPage(),
      ),
      _AdminFeature(
        title: 'Bookings',
        icon: Icons.calendar_month_outlined,
        color: Colors.orange,
        destination: StatusListPage(),
      ),
      _AdminFeature(
        title: 'Requests',
        icon: Icons.request_page_outlined,
        color: Colors.deepPurple,
        destination: ServiceRequestPage(),
      ),
      _AdminFeature(
        title: 'Profile',
        icon: Icons.person_outline,
        color: Colors.blueGrey,
        destination: ProfileScreen(),
      ),
    ];

    final List<String> carouselImages = [
      'assets/ppt1.jpg',
      'assets/ppt1.jpg',
      'assets/ppt1.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text("Cleaning",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// Carousel
          CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
            ),
            items: carouselImages.map((imagePath) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 50),

          /// Feature Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              itemCount: features.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final feature = features[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => feature.destination),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: feature.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: feature.color.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: feature.color.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: feature.color.withOpacity(0.15),
                          radius: 30,
                          child: Icon(feature.icon, color: feature.color, size: 30),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          feature.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: feature.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminFeature {
  final String title;
  final IconData icon;
  final Color color;
  final Widget destination;

  const _AdminFeature({
    required this.title,
    required this.icon,
    required this.color,
    required this.destination,
  });
}
