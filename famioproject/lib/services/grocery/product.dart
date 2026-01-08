import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/grocery/product_model.dart';

class ProductService {
  final CollectionReference _productRef =
      FirebaseFirestore.instance.collection('products');

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
    await _productRef.add(product.toMap());
  }

  // 🔹 Update product ✅
  Future<void> updateProduct(Product product) async {
    await _productRef.doc(product.id).update({
      'name': product.name,
      'price': product.price,
      // do NOT update createdAt
    });
  }

  // 🔹 Delete product
  Future<void> deleteProduct(String id) async {
    await _productRef.doc(id).delete();
  }
}
