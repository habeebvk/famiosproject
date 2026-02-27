import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/grocery/product_model.dart';

class ProductService {
  final CollectionReference _productRef = FirebaseFirestore.instance.collection(
    'products',
  );

  // 🔹 Get products (real-time)
  Stream<List<Product>> getProducts() {
    return _productRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  // 🔹 Add product
  Future<void> addProduct(Product product) async {
    try {
      final doc = _productRef.doc();
      await doc.set(product.copyWith(id: doc.id).toMap());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // 🔹 Update product ✅
  Future<void> updateProduct(Product product) async {
    try {
      await _productRef.doc(product.id).update(product.toUpdateMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // 🔹 Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _productRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}
