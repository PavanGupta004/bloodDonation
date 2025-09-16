import 'package:cloud_firestore/cloud_firestore.dart'
    show GeoPoint, FirebaseFirestore, FieldValue;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSViewDetailsPage extends StatefulWidget {
  final String requestId;
  const SOSViewDetailsPage({super.key, required this.requestId});

  @override
  State<SOSViewDetailsPage> createState() => _SOSViewDetailsPageState();
}

class _SOSViewDetailsPageState extends State<SOSViewDetailsPage> {
  // Temporary values for demonstration
  String requesterName = "";
  String bloodGroup = "";
  String gender = "";
  String location = "";
  String kilometers = "";
  String urgencyLevel = "";
  double latitude = 0.0;
  double longitude = 0.0;

  Future<void> _launchMaps() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/place/$latitude,$longitude',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> loadRequestDetails() async {
    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      // 1️⃣ Fetch request
      final requestDoc = await _firestore
          .collection("requests")
          .doc(widget.requestId)
          .get();

      if (!requestDoc.exists) return;
      final requestData = requestDoc.data()!;

      // 2️⃣ Fetch requester details from users collection
      final requesterId = requestData["requestFrom"];
      final userDoc = await _firestore
          .collection("users")
          .doc(requesterId)
          .get();
      final userData = userDoc.exists ? userDoc.data()! : {};

      // 3️⃣ Extract details
      final String fetchedName = userData["name"] ?? "Unknown";
      final String fetchedGender = userData["gender"] ?? "Unknown";
      final String fetchedBloodGroup = requestData["bloodType"] ?? "N/A";
      final String fetchedUrgency = requestData["urgencyLevel"] ?? "Normal";

      // Location (GeoPoint to Lat/Lon)
      GeoPoint gp = requestData["location"];
      final double fetchedLat = gp.latitude;
      final double fetchedLon = gp.longitude;

      final String fetchedLocation =
          "Lat: ${gp.latitude}, Lon: ${gp.longitude}";

      // (Optional) Distance placeholder
      final String fetchedKilometers = "1.2 kms away";

      // ✅ Update state so UI rebuilds
      setState(() {
        requesterName = fetchedName;
        gender = fetchedGender;
        bloodGroup = fetchedBloodGroup;
        urgencyLevel = fetchedUrgency;
        latitude = fetchedLat;
        longitude = fetchedLon;
        location = fetchedLocation;
        kilometers = fetchedKilometers;
      });
    } catch (e) {
      print("❌ Error loading request details: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.requestId != null && widget.requestId!.isNotEmpty) {
      loadRequestDetails();
    } else {
      print("⚠️ No requestId provided to SOSViewDetailsPage");
    } // ✅ Call when page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button and Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Request Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Requested By: $requesterName'),
                  const SizedBox(height: 20),
                  Text('Blood Group: $bloodGroup'),
                  const SizedBox(height: 20),
                  Text('Gender: $gender'),
                  const SizedBox(height: 20),
                  Text('Location: $location'),
                  const SizedBox(height: 20),
                  Text('Distance: $kilometers km away'),
                  const SizedBox(height: 20),
                  Text('Urgency Level: $urgencyLevel'),
                ],
              ),
            ),

            const Spacer(), // Add this to push buttons to bottom
            // Add the buttons row
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _launchMaps();
                        print('Map button pressed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Map',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You must be logged in to donate.'),
                            ),
                          );
                          return;
                        }

                        try {
                          await FirebaseFirestore.instance
                              .collection('requests')
                              .doc(widget.requestId)
                              .update({
                                'donatedBy': user.uid,
                                'requestFulfilledAt':
                                    FieldValue.serverTimestamp(),
                                'requestFulfilled': true,
                              });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thank you for donating!'),
                            ),
                          );
                          Navigator.pop(
                            context,
                          ); // Optionally go back after success
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Donate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
