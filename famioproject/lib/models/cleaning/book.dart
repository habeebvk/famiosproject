import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String address;
  final double totalPrice;
  final String status;
  final String userName;

  Booking({
    required this.id,
    required this.address,
    required this.totalPrice,
    required this.status,
    required this.userName,
  });

  factory Booking.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Booking(
      id: doc.id,
      address: data['address'] ?? '',
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: data['status'] ?? 'pending',
      userName: data['userName'] ?? 'Unknown User',
    );
  }
}
