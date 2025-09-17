import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sos_blood_donation/database/update_details.dart';
import 'package:sos_blood_donation/pages/allRequestList.dart';
import 'package:sos_blood_donation/pages/history.dart';
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
  int totalDonation = 0;

  int donations = 7;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentStatus();
    _getTotalDonation();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _getTotalDonation() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('donatedBy', isEqualTo: userUid) // use isEqualTo for string
        .get();

    totalDonation = snapshot.docs.length;
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
      username = doc.data()?['name'] ?? 'User';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HistoryPage(), // Navigate to HistoryPage(
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                print('pressed Logout');
                _authService.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
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
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 150,
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Changed to end
              children: [
                Text(
                  'Hi, $username !',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your Donations: $totalDonation',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
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
    // }

