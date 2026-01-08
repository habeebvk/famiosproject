import 'package:cloud_firestore/cloud_firestore.dart';

class FoodProduct {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final bool available;

  FoodProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.available,
  });

  factory FoodProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodProduct(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'General',
      available: data['available'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'available': available,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
