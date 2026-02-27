import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final Timestamp? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.createdAt,
  });

  /// -------- From Firestore --------
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return Product(
      id: doc.id,
      name: data?['name'] ?? '',
      price: (data?['price'] ?? 0).toDouble(),
      imageUrl: data?['imageUrl'] ?? '',
      createdAt: data?['createdAt'],
    );
  }

  /// -------- To Firestore (Create) --------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// -------- To Firestore (Update) --------
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  /// -------- CopyWith --------
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    Timestamp? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

