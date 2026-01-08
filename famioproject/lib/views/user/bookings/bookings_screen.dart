
// Main Screen with Tabs
// -----------------------------
import 'package:flutter/material.dart';

class RequestTabScreen extends StatelessWidget {
  const RequestTabScreen({super.key});

  // Sample accepted and rejected request data
  final List<Request> acceptedRequests = const [
    Request(name: "John Doe", reason: "Appointment Approved"),
    Request(name: "Alex Johnson", reason: "Follow-up Confirmed"),
    Request(name: "Mary Green", reason: "Lab Test Approved"),
  ];

  final List<Request> rejectedRequests = const [
    Request(name: "Jane Smith", reason: "Missing Documents"),
    Request(name: "Emily White", reason: "Invalid Insurance"),
    Request(name: "Tom Black", reason: "Request Expired"),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Accepted and Rejected
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // title: const Text("Requests"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Accepted"),
              Tab(text: "Requsted"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RequestList(requests: acceptedRequests, accepted: true),
            RequestList(requests: rejectedRequests, accepted: false),
          ],
        ),
      ),
    );
  }
}

// -----------------------------
// Request List Widget
// -----------------------------
class RequestList extends StatelessWidget {
  final List<Request> requests;
  final bool accepted;

  const RequestList({super.key, required this.requests, required this.accepted});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              accepted ? Icons.check_circle : Icons.cancel,
              color: accepted ? Colors.green : Colors.red,
              size: 30,
            ),
            title: Text(
              request.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Reason: ${request.reason}"),
          ),
        );
      },
    );
  }
}

// -----------------------------
// Request Model
// -----------------------------
class Request {
  final String name;
  final String reason;

  const Request({
    required this.name,
    required this.reason,
  });
}
