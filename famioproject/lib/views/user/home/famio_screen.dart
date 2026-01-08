import 'package:carousel_slider/carousel_slider.dart';
import 'package:famioproject/views/user/cleaning&service/cleaning&service_screen.dart';
import 'package:famioproject/views/user/food/food_screen.dart';
import 'package:famioproject/views/user/grocery/grocery_screen.dart';
import 'package:famioproject/views/user/uber/uber_screen.dart' show UberBookingApp, UberBookingPage;
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imageList = [
      'assets/pppt.png',
      'assets/ppt1.jpg',
      'assets/ppt2.webp',
    ];

    final List<Map<String, dynamic>> services = [
      {
        'title': 'Grocery',
        'icon': Icons.shopping_cart_rounded,
        'color': Colors.greenAccent.shade100,
        'screen': GroceryPage(),
      },
      {
        'title': 'Uber Booking',
        'icon': Icons.local_taxi_rounded,
        'color': Colors.amber.shade100,
        'screen': UberBookingPage(),
      },
      {
        'title': 'Food Delivery',
        'icon': Icons.fastfood_rounded,
        'color': Colors.orange.shade100,
        'screen': FoodPurchasePage(),
      },
      {
        'title': 'Home Cleaning',
        'icon': Icons.cleaning_services_rounded,
        'color': Colors.lightBlue.shade100,
        'screen': BookingScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔸 Header with gradient
             
              const SizedBox(height: 20),

              // 🔹 Carousel Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 180,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      autoPlayInterval: const Duration(seconds: 3),
                    ),
                    items: imageList.map((img) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                img,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 🔸 Services Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Text(
                      "Our Services",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.more_horiz, color: Colors.black54),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Grid of Services
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final item = services[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => item['screen']),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: item['color'],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                item['icon'],
                                size: 40,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
