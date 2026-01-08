import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famioproject/models/patient.dart';

class PatientService {
  final _db = FirebaseFirestore.instance.collection('patients');

  Stream<List<Patient>> getPatients() {
    return _db
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) {
              return Patient.fromFirestore(
                  doc.data(), doc.id);
            }).toList());
  }

  Future<DocumentReference> addPatient(Patient patient) {
    return _db.add(patient.toFirestore());
  }
}

