import 'package:cloud_firestore/cloud_firestore.dart';

class UberBookingService {
  final CollectionReference _bookingRef =
      FirebaseFirestore.instance.collection('ride_bookings');

  /// Create booking
  Future<void> addBooking({
    required String name,
    required String pickup,
    required String dropOff,
    required DateTime pickupDateTime,
  }) async {
    await _bookingRef.add({
      'name': name,
      'pickup': pickup,
      'dropOff': dropOff,
      'pickupDateTime': Timestamp.fromDate(pickupDateTime),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ALL requests (used in Ride Requests page)
  Stream<List<Map<String, dynamic>>> getRideRequests() {
    return _bookingRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// ✅ ACCEPTED → Active tab
  Stream<List<Map<String, dynamic>>> getActiveRides() {
    return _bookingRef
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// ✅ COMPLETED → Completed tab
  Stream<List<Map<String, dynamic>>> getCompletedRides() {
    return _bookingRef
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Accept / Reject
  Future<void> updateStatus(String id, String status) {
    return _bookingRef.doc(id).update({'status': status});
  }

  /// Mark completed
  Future<void> markCompleted(String id) {
    return _bookingRef.doc(id).update({'status': 'completed'});
  }
}
