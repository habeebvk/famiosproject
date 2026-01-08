import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famioproject/models/grocery/orders.dart';
import 'package:famioproject/models/grocery/product_model.dart';


class OrderService {
  final CollectionReference _orderRef =
      FirebaseFirestore.instance.collection('grocery_orders');

    Future<void> createOrder({
      required List<Product> products,
      required Map<String, int> cart,
      required double totalAmount,
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

      await _orderRef.add({
        'items': items,
        'totalAmount': totalAmount,
        'status': 'pending', // ✅ REQUIRED
        'createdAt': FieldValue.serverTimestamp(),
      });
    }


    Stream<List<OrderModel>> getOrders() {
    return _orderRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderRef.doc(orderId).update({'status': status});
  }
}
