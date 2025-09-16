import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Parse location safely (supports both GeoPoint and String format)
  GeoPoint parseLocation(dynamic loc) {
    if (loc is GeoPoint) {
      return loc;
    } else if (loc is String) {
      // Example input: [12.9716° N, 77.5946° E]
      loc = loc.replaceAll(RegExp(r'[\[\]°]'), '').trim();
      final parts = loc.split(',');
      final latParts = parts[0].trim().split(' ');
      final lonParts = parts[1].trim().split(' ');

      double lat = double.parse(latParts[0]) * (latParts[1] == "S" ? -1 : 1);
      double lon = double.parse(lonParts[0]) * (lonParts[1] == "W" ? -1 : 1);

      return GeoPoint(lat, lon);
    } else {
      throw Exception("Invalid location format: $loc");
    }
  }

  // ✅ Haversine formula
  double calculateDistance(GeoPoint start, GeoPoint end) {
    const double R = 6371; // Earth radius in km
    double dLat = _deg2rad(end.latitude - start.latitude);
    double dLon = _deg2rad(end.longitude - start.longitude);

    double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(start.latitude)) *
            cos(_deg2rad(end.latitude)) *
            (sin(dLon / 2) * sin(dLon / 2));

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // ✅ Find nearby donors from a request
  Future<List<Map<String, dynamic>>> findNearbyDonors(
    String requestId,
    double maxDistanceKm,
  ) async {
    try {
      // Get request data
      DocumentSnapshot requestDoc = await _firestore
          .collection("requests")
          .doc(requestId)
          .get();

      if (!requestDoc.exists) return [];

      var requestData = requestDoc.data() as Map<String, dynamic>;
      GeoPoint requesterLocation = parseLocation(requestData["location"]);
      String requestedBloodType = requestData["bloodType"];

      // Get all matching donors
      QuerySnapshot donorsSnap = await _firestore
          .collection("users")
          .where("isAvailableForDonating", isEqualTo: true)
          .where("bloodType", isEqualTo: requestedBloodType)
          .get();

      List<Map<String, dynamic>> nearbyDonors = [];

      for (var doc in donorsSnap.docs) {
        var donorData = doc.data() as Map<String, dynamic>;
        GeoPoint donorLocation = parseLocation(donorData["location"]);

        double distance = calculateDistance(requesterLocation, donorLocation);

        if (distance <= maxDistanceKm) {
          nearbyDonors.add({
            "uid": doc.id,
            "name": donorData["name"],
            "bloodType": donorData["bloodType"],
            "phone": donorData["phone"],
            "distanceKm": distance,
          });
        }
      }

      // Sort by nearest
      nearbyDonors.sort((a, b) => (a["distanceKm"]).compareTo(b["distanceKm"]));

      return nearbyDonors;
    } catch (e) {
      print("❌ Error finding nearby donors: $e");
      return [];
    }
  }
}
