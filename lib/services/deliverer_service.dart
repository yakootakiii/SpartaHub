import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DelivererService {
  /// Creates a deliverer profile in Firestore
  static Future<void> createDelivererProfile(
    User user,
    String fullName,
    String email,
  ) async {
    final delivererDoc = FirebaseFirestore.instance
        .collection('deliverers')
        .doc(user.uid);

    await delivererDoc.set({
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
