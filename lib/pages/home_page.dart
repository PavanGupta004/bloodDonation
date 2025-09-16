import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sos_blood_donation/database/update_details.dart';
import 'package:sos_blood_donation/pages/allRequestList.dart';
import 'package:sos_blood_donation/pages/sos_request_page.dart';
import 'package:sos_blood_donation/services/auth_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "User";
  final AuthService _authService = AuthService();
  bool isAvailable = false;
  final UpdateData _updateData = UpdateData();

  int donations = 7;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentStatus();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _fetchCurrentStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      isAvailable = doc.data()?['isAvailableForDonating'] ?? false;
    });
  }

  void _toggleAvailability() async {
    await _updateData.toggleDonorAvailability();
    _fetchCurrentStatus(); // refresh the button
  }

  void _toggleSwitch(bool value) async {
    setState(() {
      isAvailable = value;
    });

    // Call your Firestore toggle method
    await _updateData.toggleDonorAvailability(); // your method
  }

  @override
  Widget build(BuildContext context) {
    // The main layout structure of the page
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Makes the content scrollable to prevent overflow on smaller screens
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Builds the top red header section
            _buildHeader(),
            // Builds the "Urgent SOS Alerts" section with cards
            _buildUrgentAlerts(),
            // Builds the "Nearby Camps" map view
          ],
        ),
      ),

      // SOS Button
      floatingActionButton: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.red,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const SOSRequestPage(),
              ),
            );
          },
          child: const Text(
            'SOS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // Bottom Navigation Bar
    );
  }

  // Widget for the top red header section
  Widget _buildHeader() {
    // Stack allows layering widgets on top of each other (e.g., Quick Donate button over the header)
    return Stack(
      clipBehavior: Clip
          .none, // Allows the "Quick Donate" button to overflow the red container
      alignment: Alignment.topCenter,
      children: [
        // The main red background container
        Container(
          height: 225,
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _authService.signOut();
                      },
                      child: Icon(Icons.logout),
                    ),
                    Text(
                      'Hi, $username !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Your Donations',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      donations.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // The circular "Quick Donate" button positioned over the header
        Positioned(
          top: 70,
          right: 30,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.red, size: 40),
                Text(
                  'Quick Donate',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        //Toggle button here
      ],
    );
  }

  // Widget for the "Urgent SOS Alerts" section
  Widget _buildUrgentAlerts() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Available for Blood Donation?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Not Available"),
                  SizedBox(width: 5),
                  Switch(
                    value: isAvailable,
                    onChanged: _toggleSwitch,
                    activeColor: Colors.redAccent,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                  SizedBox(width: 5),
                  const Text("Available"),
                ],
              ),
            ],
          ),
          // First alert card (not critical)
          Container(height: 500, child: RequestsPage()),
        ],
      ),
    );
  }
}
