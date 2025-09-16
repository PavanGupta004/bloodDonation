import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user and save data
  Future<User?> createUserWithEmailAndData({
    required String email,
    required String password,
    required String name,
    String? dob,
    String? gender,
    String? bloodType,
    required String phone,
    required String type, // hospital / NGO / donor
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Create Firebase Auth user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user == null) return null;

      // Determine collection
      String collectionName;
      Map<String, dynamic> data;

      if (type == 'Donor/Requester') {
        collectionName = 'users';
        data = {
          "name": name,
          "dob": dob,
          "gender": gender,
          "bloodType": bloodType,
          "phone": phone,
          "email": email,
          "location": GeoPoint(latitude, longitude),
          "createdAt": FieldValue.serverTimestamp(),
          "type": type,
          "isAvailable": true,
        };
      } else if (type == 'Hospital') {
        collectionName = 'hospital';
        data = {
          "name": name,
          "phone": phone,
          "email": email,
          "location": GeoPoint(latitude, longitude),
          "createdAt": FieldValue.serverTimestamp(),
          "type": type,
        };
      } else if (type == 'NGO') {
        collectionName = 'ngo';
        data = {
          "name": name,
          "phone": phone,
          "email": email,
          "location": GeoPoint(latitude, longitude),
          "createdAt": FieldValue.serverTimestamp(),
          "type": type,
        };
      } else {
        throw Exception("Invalid type");
      }

      await _firestore.collection(collectionName).doc(user.uid).set(data);

      return user;
    } catch (e) {
      print("Error in createUserWithEmailAndData: $e");
      return null;
    }
  }

  Future<void> singInUser() async {}

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user logged in
  User? currentUser() => _auth.currentUser;
}
