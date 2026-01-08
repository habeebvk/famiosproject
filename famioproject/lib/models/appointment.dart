import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientName;
  final String doctorName;
  final DateTime dateTime;
  String status;

  AppointmentModel({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.dateTime,
    required this.status,
  });

  /// Firestore → Model
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppointmentModel(
      id: doc.id,
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'],
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'doctorName': doctorName,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
    };
  }
}
