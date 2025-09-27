import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  /// Creates a user profile in Firestore for the given Firebase user
  static Future<void> createUserProfile(
    User user,
    String fullName,
    String email,
  ) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    await userDoc.set({
      'fullName': fullName,
      'email': email,
      'points': 0,
      'saved': [],
      'ordersCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
