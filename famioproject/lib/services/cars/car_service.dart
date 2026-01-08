import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:famioproject/models/uber/cars.dart';

class CarFirestoreService {
  final _carRef = FirebaseFirestore.instance.collection('cars');
  final _storage = FirebaseStorage.instance;

  /// ADD
  Future<void> addCar(Car car) async {
    String? imageUrl;

    if (car.imageFile != null) {
      final ref = _storage
          .ref('cars/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(car.imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    await _carRef.add(car.toMap(imageUrl));
  }

  /// UPDATE
  Future<void> updateCar(Car car) async {
    String? imageUrl = car.imageUrl;

    if (car.imageFile != null) {
      final ref = _storage.ref('cars/${car.id}.jpg');
      await ref.putFile(car.imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    await _carRef.doc(car.id).update(car.toMap(imageUrl));
  }

  /// DELETE
  Future<void> deleteCar(String id) async {
    await _carRef.doc(id).delete();
  }

  /// GET
  Stream<List<Car>> getCars() {
    return _carRef.snapshots().map((snap) =>
        snap.docs.map((e) => Car.fromFirestore(e)).toList());
  }
}
