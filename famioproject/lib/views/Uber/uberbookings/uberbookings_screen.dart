import 'package:famioproject/services/cars/uber_booking.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UberBookingScreen extends StatelessWidget {
  UberBookingScreen({super.key});

  final UberBookingService _service = UberBookingService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "Uber Bookings",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.green,
            indicatorWeight: 4,
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(
              stream: _service.getActiveRides(), // ✅ accepted
              isActive: true,
            ),
            _buildList(
              stream: _service.getCompletedRides(),
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList({
    required Stream<List<Map<String, dynamic>>> stream,
    required bool isActive,
  }) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              isActive ? "No active bookings." : "No completed trips.",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final rides = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rides.length,
          itemBuilder: (context, index) {
            final ride = rides[index];

            return Card(
              color: Colors.white, // ✅ white card
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.black,
                          child: Icon(
                            isActive
                                ? LucideIcons.car
                                : LucideIcons.checkCircle,
                            color: isActive
                                ? Colors.green
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ride['name'] ?? '',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "From: ${ride['pickup'] ?? ''}",
                                style: const TextStyle(color: Colors.black87),
                              ),
                              Text(
                                "To: ${ride['dropOff'] ?? ''}",
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (isActive) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () =>
                              _service.markCompleted(ride['id']),
                          child: const Text("Completed"),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
