import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String id;
  final String model;
  final String plateNumber;
  final String driverName;
  final String driverContact;
  final String? imageUrl;
  final File? imageFile;

  Car({
    required this.id,
    required this.model,
    required this.plateNumber,
    required this.driverName,
    required this.driverContact,
    this.imageUrl,
    this.imageFile,
  });

  factory Car.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Car(
      id: doc.id,
      model: data['model'],
      plateNumber: data['plateNumber'],
      driverName: data['driverName'],
      driverContact: data['driverContact'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap(String? imageUrl) {
    return {
      'model': model,
      'plateNumber': plateNumber,
      'driverName': driverName,
      'driverContact': driverContact,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
