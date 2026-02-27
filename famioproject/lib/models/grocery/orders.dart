import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String name;
  final int quantity;

  OrderItem({required this.name, required this.quantity});

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(name: data['name'], quantity: data['quantity']);
  }
}

class OrderModel {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String userName;
  final String userId;
  final String? paymentId;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.userName,
    required this.userId,
    this.paymentId,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      items: (data['items'] as List).map((e) => OrderItem.fromMap(e)).toList(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      status: data['status'] ?? 'pending',
      userName: data['userName'] ?? 'Unknown User',
      userId: data['userId'] ?? '',
      paymentId: data['paymentId'],
    );
  }
}
