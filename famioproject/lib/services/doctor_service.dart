import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famioproject/models/doctors.dart';

class DoctorService {
  final _doctorRef =
      FirebaseFirestore.instance.collection('doctors');

  // Future<void> addDoctor(DoctorModel doctor) async {
  //   await _doctorRef.add(doctor.toMap());
  // }
  Future<DocumentReference> addDoctor(DoctorModel doctor) async {
  try {
    final docRef = await _doctorRef.add(doctor.toMap());
    print("✅ Doctor document created with ID: ${docRef.id}");
    return docRef;
  } catch (e, stackTrace) {
    print("❌ ERROR in addDoctor: $e");
    print("Stack trace: $stackTrace");
    rethrow; // Re-throw so the UI can catch it
  }
}

  Stream<List<DoctorModel>> getDoctors() {
    return _doctorRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs
                .map((doc) => DoctorModel.fromFirestore(doc))
                .toList());
  }

  Future<void> deleteDoctor(String id) async {
    await _doctorRef.doc(id).delete();
  }
}
