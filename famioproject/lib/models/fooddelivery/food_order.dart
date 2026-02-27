import 'package:cloud_firestore/cloud_firestore.dart';

class FoodOrder {
  final String id;
  final List<Map<String, dynamic>> items;
  final double total;
  final String address;
  final bool? accepted;
  final Timestamp createdAt;
  final String userName;

  FoodOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.address,
    this.accepted,
    required this.createdAt,
    required this.userName,
  });

  factory FoodOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodOrder(
      id: doc.id,
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      total: (data['total'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      accepted: data['accepted'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      userName: data['userName'] ?? 'Unknown User',
    );
  }
}
