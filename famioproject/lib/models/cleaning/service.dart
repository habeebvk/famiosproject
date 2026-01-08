import 'package:cloud_firestore/cloud_firestore.dart';


class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  bool isSelected;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.isSelected = false,
  });

  /// 🔹 Convert Firestore → Model
factory Service.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data() as Map<String, dynamic>;
  return Service(
    id: doc.id,
    name: data['name'] ?? '',
    description: data['description'] ?? '',
    price: (data['price'] ?? 0).toDouble(),
  );
}


  /// 🔹 Convert Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

