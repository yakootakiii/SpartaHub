import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerService {
  /// Creates a seller profile in Firestore
  static Future<void> createSellerProfile(
    User user,
    String fullName,
    String email,
  ) async {
    final sellerDoc = FirebaseFirestore.instance
        .collection('sellers')
        .doc(user.uid);

    await sellerDoc.set({
      'fullName': fullName,
      'email': email,
      'products': [],
      'activeOrders': [],
      'pastOrders': [],
      'earnings': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
