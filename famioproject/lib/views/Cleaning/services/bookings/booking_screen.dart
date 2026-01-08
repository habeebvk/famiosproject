import 'package:famioproject/models/cleaning/book.dart';
import 'package:famioproject/services/cleaning/service_clean.dart';
import 'package:flutter/material.dart';

class StatusListPage extends StatelessWidget {
  const StatusListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            'Requests Status',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Accepted"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _StatusTab(status: 'accepted'),
            _StatusTab(status: 'rejected'),
          ],
        ),
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String status;
  const _StatusTab({required this.status});

  @override
  Widget build(BuildContext context) {
    final service = ServiceFirestoreService();

    return StreamBuilder<List<Booking>>(
      stream: service.getBookingsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No ${status} requests",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final bookings = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  status == 'accepted'
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: status == 'accepted'
                      ? Colors.green
                      : Colors.red,
                  size: 30,
                ),
                title: Text(
                  "Booking #${booking.id.substring(0, 6)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Address: ${booking.address}"),
                    Text("Total: ₹${booking.totalPrice.toStringAsFixed(2)}"),
                  ],
                ),
                trailing: Icon(
                  status == 'accepted'
                      ? Icons.verified
                      : Icons.block,
                  color: status == 'accepted'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            );
          },
        );
      },
    );
  }
}


