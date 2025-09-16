import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
          "uid": user.uid,
          "name": name,
          "dob": dob,
          "gender": gender,
          "bloodType": bloodType,
          "phone": phone,
          "email": email,
          "location": GeoPoint(latitude, longitude),
          "createdAt": FieldValue.serverTimestamp(),
          "type": type,
          "isAvailableForDonating": true,
        };
      } else if (type == 'Hospital') {
        collectionName = 'hospital';
        data = {
          "hospitalId": user.uid,
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
          "ngo": user.uid,
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

  Future<User?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        print("Wrong password provided.");
      } else {
        print("FirebaseAuthException: ${e.code} - ${e.message}");
      }
      return null;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Check if user logged in
  User? currentUser() => _auth.currentUser;
}
