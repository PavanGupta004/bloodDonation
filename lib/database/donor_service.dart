import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Parse location safely (supports GeoPoint or String "[lat, lon]" format)
  GeoPoint parseLocation(dynamic loc) {
    // Already a GeoPoint
    if (loc is GeoPoint) {
      return loc;
    }
    // String format: "[12.9716° N, 77.5946° E]"
    else if (loc is String) {
      try {
        // Remove brackets and degree symbols
        loc = loc.replaceAll(RegExp(r'[\[\]°]'), '').trim();
        // Split into latitude and longitude parts
        final parts = loc.split(',');
        if (parts.length != 2) throw Exception("Invalid location format");

        final latParts = parts[0].trim().split(' ');
        final lonParts = parts[1].trim().split(' ');

        double lat =
            double.parse(latParts[0]) *
            (latParts[1].toUpperCase() == "S" ? -1 : 1);
        double lon =
            double.parse(lonParts[0]) *
            (lonParts[1].toUpperCase() == "W" ? -1 : 1);

        return GeoPoint(lat, lon);
      } catch (e) {
        throw Exception("Failed to parse location string: $e");
      }
    }
    // Invalid type
    else {
      throw Exception("Invalid location type: ${loc.runtimeType}");
    }
  }

  // Haversine formula for distance in KM
  double calculateDistance(GeoPoint start, GeoPoint end) {
    const double R = 6371; // Earth radius in km
    double dLat = _deg2rad(end.latitude - start.latitude);
    double dLon = _deg2rad(end.longitude - start.longitude);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(start.latitude)) *
            cos(_deg2rad(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // Find nearby donors for a given request
  Future<List<Map<String, dynamic>>> findNearbyDonors(
    String requestId,
    double maxDistanceKm,
  ) async {
    try {
      print("🔍 Starting search for request: $requestId");

      // 1️⃣ Fetch request
      DocumentSnapshot requestDoc = await _firestore
          .collection("requests")
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        print("❌ Request document not found");
        return [];
      }

      var requestData = requestDoc.data() as Map<String, dynamic>;
      print("📋 Request data: $requestData");

      // 2️⃣ Get requester location safely
      GeoPoint requesterLocation;
      try {
        if (requestData["location"] is GeoPoint) {
          requesterLocation = requestData["location"];
        } else {
          requesterLocation = parseLocation(requestData["location"]);
        }
        print(
          "📍 Requester location: ${requesterLocation.latitude}, ${requesterLocation.longitude}",
        );
      } catch (e) {
        print("❌ Failed to parse requester location: $e");
        return [];
      }

      String requestedBloodType =
          requestData["bloodType"]?.toString().trim() ?? "";
      String requesterUid = requestData["requestFrom"] ?? "";

      print("🩸 Requested blood type: '$requestedBloodType'");
      print("👤 Requester UID: $requesterUid");

      if (requestedBloodType.isEmpty) {
        print("❌ Blood type is empty");
        return [];
      }

      // 3️⃣ Compatible donors map
      final Map<String, List<String>> compatibleDonors = {
        "A+": ["A+", "A-", "O+", "O-"],
        "A-": ["A-", "O-"],
        "B+": ["B+", "B-", "O+", "O-"],
        "B-": ["B-", "O-"],
        "AB+": ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"],
        "AB-": ["A-", "B-", "AB-", "O-"],
        "O+": ["O+", "O-"],
        "O-": ["O-"],
      };

      final allowedTypes =
          compatibleDonors[requestedBloodType] ?? [requestedBloodType];
      print("✅ Compatible blood types: $allowedTypes");

      // 4️⃣ First, let's get all available donors to debug
      QuerySnapshot allDonorsSnap = await _firestore
          .collection("users")
          .where("isAvailableForDonating", isEqualTo: true)
          .get();

      print("👥 Total available donors: ${allDonorsSnap.docs.length}");

      // Debug: Print blood types of available donors
      Map<String, int> bloodTypeCount = {};
      for (var doc in allDonorsSnap.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String bloodType = data["bloodType"]?.toString().trim() ?? "Unknown";
        bloodTypeCount[bloodType] = (bloodTypeCount[bloodType] ?? 0) + 1;
      }
      print("📊 Blood type distribution: $bloodTypeCount");

      // 5️⃣ Query donors with compatible types
      // Since whereIn has a limit of 10 items, we're safe here
      QuerySnapshot donorsSnap = await _firestore
          .collection("users")
          .where("isAvailableForDonating", isEqualTo: true)
          .where("bloodType", whereIn: allowedTypes)
          .get();

      print("🔍 Donors with compatible blood types: ${donorsSnap.docs.length}");

      List<Map<String, dynamic>> nearbyDonors = [];

      for (var doc in donorsSnap.docs) {
        try {
          if (doc.id == requesterUid) {
            print("⏭️ Skipping requester: ${doc.id}");
            continue;
          }

          var donorData = doc.data() as Map<String, dynamic>;
          print(
            "👤 Processing donor: ${doc.id} - ${donorData['name']} (${donorData['bloodType']})",
          );

          // Check if location exists and parse it
          GeoPoint donorLocation;
          if (donorData["location"] == null) {
            print("⚠️ Donor ${doc.id} has no location data");
            continue;
          }

          if (donorData["location"] is GeoPoint) {
            donorLocation = donorData["location"];
          } else {
            try {
              donorLocation = parseLocation(donorData["location"]);
            } catch (e) {
              print("⚠️ Failed to parse location for donor ${doc.id}: $e");
              continue;
            }
          }

          print(
            "📍 Donor location: ${donorLocation.latitude}, ${donorLocation.longitude}",
          );

          double distance = calculateDistance(requesterLocation, donorLocation);
          print("📏 Distance: ${distance.toStringAsFixed(2)} km");

          if (distance <= maxDistanceKm) {
            nearbyDonors.add({
              "uid": doc.id,
              "name": donorData["name"] ?? "Unknown",
              "bloodType": donorData["bloodType"] ?? "Unknown",
              "phone": donorData["phone"] ?? "N/A",
              "distanceKm": double.parse(distance.toStringAsFixed(2)),
            });
            print(
              "✅ Added nearby donor: ${donorData['name']} (${distance.toStringAsFixed(2)} km)",
            );
          } else {
            print(
              "❌ Donor too far: ${distance.toStringAsFixed(2)} km > $maxDistanceKm km",
            );
          }
        } catch (e) {
          print("⚠️ Error processing donor ${doc.id}: $e");
          continue;
        }
      }

      // Sort by distance
      nearbyDonors.sort((a, b) => a["distanceKm"].compareTo(b["distanceKm"]));
      print("🎯 Final nearby donors found: ${nearbyDonors.length}");

      for (var donor in nearbyDonors) {
        print(
          "   - ${donor['name']} (${donor['bloodType']}) - ${donor['distanceKm']} km",
        );
      }

      return nearbyDonors;
    } catch (e) {
      print("❌ Error finding nearby donors: $e");
      return [];
    }
  }
}
