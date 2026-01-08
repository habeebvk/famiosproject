import 'package:famioproject/services/cars/uber_booking.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UberRideRequestsPage extends StatefulWidget {
  const UberRideRequestsPage({super.key});

  @override
  State<UberRideRequestsPage> createState() => _UberRideRequestsPageState();
}

class _UberRideRequestsPageState extends State<UberRideRequestsPage> {
  final UberBookingService _service = UberBookingService();


  void _acceptRide(String id) {
    _service.updateStatus(id, 'accepted');
  }

  void _rejectRide(String id) {
    _service.updateStatus(id, 'rejected');
  }


  Widget _statusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'accepted':
        color = Colors.green;
        text = 'ACCEPTED';
        break;
      case 'rejected':
        color = Colors.redAccent;
        text = 'REJECTED';
        break;
      default:
        color = Colors.orangeAccent;
        text = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Ride Requests',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
  stream: _service.getRideRequests(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(
        child: Text(
          "No ride requests yet.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final rideRequests = snapshot.data!;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rideRequests.length,
      itemBuilder: (context, index) {
        final ride = rideRequests[index];
        final status = ride['status'] ?? 'pending';

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          margin: const EdgeInsets.only(bottom: 18),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rider + Status
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ride['name'] ?? 'Unknown Rider',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _statusBadge(status),
                    ],
                  ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ride['pickup'])),
                  ],
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(LucideIcons.navigation, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ride['dropOff'])),
                  ],
                ),
                const SizedBox(height: 12),

                if (status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () => _acceptRide(ride['id']),
                          child: const Text("Accept"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () => _rejectRide(ride['id']),
                          child: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  },
),
    );
  }
}
