import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famioproject/models/appointment.dart';
import 'package:famioproject/models/doctors.dart';
import 'package:famioproject/views/Hospital/home/hospitalhome_screen.dart';



/// Appointment Service – handles all Firebase operations
class AppointmentService {
  /// Firestore reference
  final CollectionReference _appointmentsRef =
      FirebaseFirestore.instance.collection('appointments');

  /// ---------------- FETCH ALL APPOINTMENTS ----------------
  Future<List<AppointmentModel>> fetchAppointments() async {
    try {
      final snapshot = await _appointmentsRef
          .orderBy('dateTime', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  /// ---------------- FETCH BY STATUS ----------------
  Future<List<AppointmentModel>> fetchAppointmentsByStatus(String status) async {
    try {
      final snapshot = await _appointmentsRef
          .where('status', isEqualTo: status)
          .orderBy('dateTime')
          .get();

      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch appointments by status: $e');
    }
  }

  /// ---------------- APPROVE APPOINTMENT ----------------
  Future<void> approveAppointment(String id) async {
    await _appointmentsRef.doc(id).update({'status': 'Approved'});
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String id) async {
    await _appointmentsRef.doc(id).update({'status': 'Cancelled'});
  }
}








