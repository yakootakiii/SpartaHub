import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourierService {
  /// Creates a deliverer profile in Firestore
  static Future<void> createCourierProfile(
    User user,
    String fullName,
    String email,
  ) async {
    final courierDoc = FirebaseFirestore.instance
        .collection('couriers')
        .doc(user.uid);

    await courierDoc.set({
      'fullName': fullName,
      'email': email,
      'activeDeliveries': [],
      'completedDeliveries': [],
      'earnings': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
