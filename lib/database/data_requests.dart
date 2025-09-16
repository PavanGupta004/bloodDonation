import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestData {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // List of possible collections
    final collections = ['users', 'hospital', 'ngo'];

    for (String collection in collections) {
      final doc = await _firestore.collection(collection).doc(uid).get();
      if (doc.exists) {
        return doc.data()!..addAll({
          'collection': collection,
        }); // optional: know which collection
      }
    }

    return null; // user not found in any collection
  }

  //Push Request to Firebase
  Future<void> pushRequest({
    required String? bloodType,
    required double latitude,
    required double longitude,
    required String urgency,
    required int quantity,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No authenticated user found.");
      return;
    }

    final userData =
        await getUserData(); // fetches data from users/hospital/ngo

    if (userData != null) {
      print("User exists in ${userData['collection']} collection");
      print("Name: ${userData['name']}");

      final requestId = _firestore.collection('requests').doc().id;

      Map<String, dynamic> data = {
        "requestId": requestId, // Unique request ID
        "bloodType": bloodType,
        "location": GeoPoint(latitude, longitude), // Geo location
        "urgencyLevel": urgency,
        "quantity": quantity,
        "requestFrom": user.uid, // UID of the requester
        "requestFromType": userData['collection'], // users / ngo / hospital
        "requestDateTime": FieldValue.serverTimestamp(),
        "requestFulfilled": false,
        "requestFulfilledAt": null,
        "donatedBy": null,
      };

      await _firestore.collection('requests').doc(requestId).set(data);
      print("Request pushed successfully with ID: $requestId");
    } else {
      print("User not found in any collection");
    }
  }

  Future<List<Map<String, dynamic>>> fetchUnfulfilledRequests() async {
    try {
      // Query requests where requestFulfilled == false
      QuerySnapshot snapshot = await _firestore
          .collection('requests')
          .where('requestFulfilled', isEqualTo: false)
          .orderBy(
            'requestDateTime',
            descending: true,
          ) // optional: recent first
          .get();

      // Map each document to a Map<String, dynamic>
      List<Map<String, dynamic>> requests = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // keep document ID if needed
        return data;
      }).toList();

      return requests;
    } catch (e) {
      print("Error fetching unfulfilled requests: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDonatedHistory(String userUid) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('requests')
          .where('donatedBy', isEqualTo: userUid)
          .orderBy('requestFulfilledAt', descending: true)
          .get();

      List<Map<String, dynamic>> history = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // optional: keep document ID
        return data;
      }).toList();

      return history;
    } catch (e) {
      print("Error fetching donated history: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRequestedHistory(String userUid) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('requests')
          .where('requestFrom', isEqualTo: userUid)
          .orderBy('requestDateTime', descending: true)
          .get();

      List<Map<String, dynamic>> history = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      return history;
    } catch (e) {
      print("Error fetching requested history: $e");
      return [];
    }
  }
}
