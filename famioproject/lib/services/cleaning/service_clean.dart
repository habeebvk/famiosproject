import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famioproject/models/cleaning/book.dart';
import 'package:famioproject/models/cleaning/service.dart';

class ServiceFirestoreService {
  final _serviceCollection =
      FirebaseFirestore.instance.collection('services');

  final _bookingCollection =
      FirebaseFirestore.instance.collection('bookings');

  /// ✅ ADD BOOKING (FIXED)
  Future<void> addBooking({
    required String address,
    required DateTime date,
    required String time,
    required double totalPrice,
    required List<Service> services,
  }) async {
    await _bookingCollection.add({
      'address': address,
      'date': Timestamp.fromDate(date),
      'time': time,
      'totalPrice': totalPrice,
      'services': services
          .map((s) => {
                'id': s.id,
                'name': s.name,
                'price': s.price,
              })
          .toList(),
      'status': 'pending', // ⭐ REQUIRED
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ✅ ADD SERVICE
  Future<void> addService(Service service) async {
    await _serviceCollection.add({
      'name': service.name,
      'description': service.description,
      'price': service.price,
    });
  }


  /// ✅ GET SERVICES
    Stream<List<Service>> getServices() {
      return FirebaseFirestore.instance
          .collection('services')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return Service.fromFirestore(doc);
            }).toList();
          });
    }

  /// ✅ GET BOOKINGS (FIXED)
  Stream<List<Booking>> getBookings() {
    return _bookingCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((e) => Booking.fromFirestore(e)).toList());
  }

  /// ✅ UPDATE STATUS (FIXED)
  Future<void> updateStatus(String id, String status) async {
    await _bookingCollection.doc(id).update({'status': status});
  }

  Stream<List<Booking>> getBookingsByStatus(String status) {
  return FirebaseFirestore.instance
      .collection('bookings') // 🔴 confirm collection name
      .where('status', isEqualTo: status)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Booking.fromFirestore(doc))
            .toList();
      });
}

}
