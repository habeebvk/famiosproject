import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl; // 🔹 NEW FIELD

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  /// -------- From Firestore --------
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '', // 🔹 SAFE FETCH
    );
  }

  /// -------- To Firestore --------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl, // 🔹 STORED URL
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}


