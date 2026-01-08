import 'package:famioproject/models/cleaning/book.dart';
import 'package:famioproject/services/cleaning/service_clean.dart';
import 'package:flutter/material.dart';

class ServiceRequestPage extends StatefulWidget {
  const ServiceRequestPage({super.key});

  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  final ServiceFirestoreService _service = ServiceFirestoreService();

  void _accept(String id) async {
    await _service.updateStatus(id, 'accepted');
  }

  void _reject(String id) async {
    await _service.updateStatus(id, 'rejected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Service Requests',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Booking>>(
        stream: _service.getBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No requests available"));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ListTile(
                  title: Text("Booking #${booking.id.substring(0, 6)}"),
                  subtitle: Text(
                    "Address: ${booking.address}\n"
                    "Total: ₹${booking.totalPrice}\n"
                    "Status: ${booking.status.toUpperCase()}",
                  ),
                  isThreeLine: true,
                  trailing: booking.status == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _accept(booking.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _reject(booking.id),
                            ),
                          ],
                        )
                      : booking.status == 'accepted'
                          ? const Icon(Icons.check_circle,
                              color: Colors.green)
                          : const Icon(Icons.cancel, color: Colors.red),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
