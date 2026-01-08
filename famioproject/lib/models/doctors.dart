import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final Timestamp? createdAt;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialization': specialization,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      createdAt: data['createdAt'],
    );
  }
}
