import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class UpdateData {
  Future<void> toggleDonorAvailability() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);

    // Get current value
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final currentStatus = snapshot.data()?['isAvailableForDonating'] ?? false;

    // Toggle value
    await docRef.update({'isAvailableForDonating': !currentStatus});

    print("Availability toggled to ${!currentStatus}");
  }
}
