import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famioproject/models/fooddelivery/food_order.dart';
import 'package:famioproject/models/fooddelivery/food_product.dart';
import 'package:famioproject/services/auth_services.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FoodProductService {
  final CollectionReference _ref = FirebaseFirestore.instance.collection(
    'food_products',
  );

  final CollectionReference _orderRef = FirebaseFirestore.instance.collection(
    'food_orders',
  );

  /// 🔹 GET PRODUCTS (Realtime)
  Stream<List<FoodProduct>> getProducts() {
    return _ref.snapshots().map(
      (s) => s.docs.map((d) => FoodProduct.fromFirestore(d)).toList(),
    );
  }

  Future<void> placeOrder(
    List<Map<String, dynamic>> items,
    double total,
  ) async {
    try {
      final userData = await AuthService().getCurrentUserData();
      final userName = userData?['name'] ?? 'Unknown User';

      await _orderRef.add({
        'items': items,
        'total': total,
        'userName': userName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  Stream<List<FoodOrder>> getOrders() {
    return _orderRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => FoodOrder.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateOrderStatus(String id, bool status) async {
    try {
      await _orderRef.doc(id).update({'accepted': status});
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// 🔹 ADD PRODUCT
  Future<void> addProduct({
    required String name,
    required double price,
    required File? imageFile,
    required String category,
    required bool available,
  }) async {
    try {
      String imageUrl = '';

      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      await _ref.add({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'available': available,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  /// 🔹 UPDATE PRODUCT
  Future<void> updateProduct({
    required String id,
    required String name,
    required double price,
    File? imageFile,
    required String category,
    required bool available,
    required String oldImageUrl,
  }) async {
    try {
      String imageUrl = oldImageUrl;

      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      await _ref.doc(id).update({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'available': available,
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// 🔹 DELETE PRODUCT
  Future<void> deleteProduct(String id) async {
    try {
      await _ref.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// 🔹 IMAGE UPLOAD
  Future<String> _uploadImage(File file) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'food_products/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
