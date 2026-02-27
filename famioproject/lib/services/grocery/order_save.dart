import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famioproject/models/grocery/orders.dart';
import 'package:famioproject/models/grocery/product_model.dart';
import 'package:famioproject/services/auth_services.dart';

class OrderService {
  final CollectionReference _orderRef = FirebaseFirestore.instance.collection(
    'grocery_orders',
  );

  Future<void> createOrder({
    required List<Product> products,
    required Map<String, int> cart,
    required double totalAmount,
    String? paymentId,
  }) async {
    final items = cart.entries.map((entry) {
      final product = products.firstWhere((p) => p.id == entry.key);
      return {
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'quantity': entry.value,
      };
    }).toList();

    final userData = await AuthService().getCurrentUserData();
    final userName = userData?['name'] ?? 'Unknown User';
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    await _orderRef.add({
      'items': items,
      'totalAmount': totalAmount,
      'status': 'pending', // ✅ REQUIRED
      'userName': userName,
      'userId': userId,
      'paymentId': paymentId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OrderModel>> getUserOrders() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return _orderRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<OrderModel>> getOrders() {
    return _orderRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderRef.doc(orderId).update({'status': status});
  }
}
