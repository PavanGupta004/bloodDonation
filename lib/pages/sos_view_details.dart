import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSViewDetailsPage extends StatefulWidget {
  const SOSViewDetailsPage({super.key});

  @override
  State<SOSViewDetailsPage> createState() => _SOSViewDetailsPageState();
}

class _SOSViewDetailsPageState extends State<SOSViewDetailsPage> {
  // Temporary values for demonstration
  final String requesterName = "John Doe";
  final String bloodGroup = "A+";
  final String gender = "Male";
  final String location = "City General Hospital";
  final String kilometers = "1.2 kms away";
  final String urgencyLevel = "Critical";
  double latitude = 37.7749; // Example latitude
  double longitude = 12.4194; // Example longitude

  Future<void> _launchMaps() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps$latitude,$longitude',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
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
                      onPressed: () {
                        print('Donate button pressed');
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
