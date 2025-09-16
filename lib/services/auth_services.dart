import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collectionName = '';

  /// Create user with email & password and save additional details in Firestore
  Future<User?> createUserWithEmailAndData({
    required String email,
    required String password,
    required String name,
    required String dob,
    required String gender,
    required String location,
    required String bloodType,
    required String phone,
    required String userType, // Hospital / NGO / Donor
  }) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // Decide collection name based on userType

        if (userType == 'Donor/Requester') {
          collectionName = 'users';
        } else {
          collectionName = userType.toLowerCase();
        }
        // hospital, ngo, donor (normalize text)

        // Save user data in the respective collection
        await _firestore.collection(collectionName).doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'dob': dob,
          'gender': gender,
          'location': location,
          'bloodType': bloodType,
          'phone': phone,
          'type': userType,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return user;
      }
    } catch (e) {
      print("Error during registration: $e");
      rethrow;
    }
    return null;
  }

  /// Sign in existing user
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
