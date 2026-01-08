import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String assignedDoctor;
  final String disease;
  final DateTime admissionDateTime;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.assignedDoctor,
    required this.disease,
    required this.admissionDateTime,
  });

  factory Patient.fromFirestore(Map<String, dynamic> data, String id) {
    return Patient(
      id: id,
      name: data['name'],
      age: data['age'],
      assignedDoctor: data['assignedDoctor'],
      disease: data['disease'],
      admissionDateTime:
          (data['admissionDateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'assignedDoctor': assignedDoctor,
      'disease': disease,
      'admissionDateTime':
          Timestamp.fromDate(admissionDateTime),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
