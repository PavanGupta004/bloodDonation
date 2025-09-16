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
              leading: const Icon(Icons.request_page),
              title: const Text('Current Request'),
              onTap: () {
                print('pressed Current Request');
                Navigator.pop(context);
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
                  'Your Donations $donations',
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

// Unused Widgets 

  // The circular "Quick Donate" button positioned over the header
    // Positioned(
    //   top: 70,
    //   right: 30,
    //   child: Container(
    //     width: 110,
    //     height: 110,
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       shape: BoxShape.circle,
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.black.withOpacity(0.3),
    //           spreadRadius: 1,
    //           blurRadius: 5,
    //         ),
    //       ],
    //     ),
    //     child: const Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Icon(Icons.add, color: Colors.red, size: 40),
    //         Text(
    //           'Quick Donate',
    //           style: TextStyle(
    //             color: Colors.red,
    //             fontWeight: FontWeight.bold,
    //             fontSize: 10,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // ),

  // Box shadow for critical alert cards
    // decoration: BoxDecoration(
    //         boxShadow: isCritical
    //             ? [
    //                 BoxShadow(
    //                   color: Colors.red.withOpacity(0.5),
    //                   // blurRadius: 12.0,
    //                   spreadRadius: 2.0,
    //                 ),
    //               ]
    //             : [],
    //       ),

  // Widget for the "Nearby Camps" section
    // Widget _buildNearbyCamps() {
    //   return Padding(
    //     padding: const EdgeInsets.all(20.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         // Section title
    //         const Text(
    //           'Nearby Camps',
    //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //         ),
    //         const SizedBox(height: 10),
    //         // Card containing the map image
    //         Card(
    //           clipBehavior: Clip.antiAlias,
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(15),
    //           ),
    //           child: Image.network(
    //             'https://i.imgur.com/2nOLqf3.png', // A placeholder map image
    //             height: 150,
    //             width: double.infinity,
    //             fit: BoxFit.cover,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

  // The navigation bar at the bottom of the screen
    // bottomNavigationBar: CurvedNavigationBar(
    //   backgroundColor: Colors.transparent,
    //   buttonBackgroundColor: Colors.red,
    //   color: Colors.grey.shade300,
    //   items: const [
    //     CurvedNavigationBarItem(
    //       child: Icon(Icons.home_outlined),
    //       label: 'Home',
    //     ),
    //     CurvedNavigationBarItem(
    //       child: Icon(Icons.notifications_outlined),
    //       label: 'Alerts',
    //     ),
    //     CurvedNavigationBarItem(
    //       child: Icon(Icons.people_outline),
    //       label: 'Camps',
    //     ),
    //     CurvedNavigationBarItem(
    //       child: Icon(Icons.chat_bubble_outline),
    //       label: 'Chat',
    //     ),
    //     CurvedNavigationBarItem(
    //       child: Icon(Icons.science_outlined),
    //       label: 'Profile/Impact',
    //     ),
    //   ],
    //   onTap: _onItemTapped,
    //   index: _selectedIndex,
    // )

  // Widget for the "Achievements" section
    // Widget _buildAchievements() {
    //   return Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         // Section title
    //         const Text(
    //           'Achievements',
    //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //         ),
    //         const SizedBox(height: 10),
    //         // Horizontally scrollable list of achievements
    //         SizedBox(
    //           height: 100,
    //           child: ListView(
    //             scrollDirection: Axis.horizontal,
    //             children: [
    //               _buildAchievementItem(
    //                 Icons.bloodtype,
    //                 '3',
    //                 '3 Donations',
    //                 Colors.brown,
    //               ),
    //               _buildAchievementItem(
    //                 Icons.star,
    //                 'First',
    //                 'First Responder',
    //                 Colors.red,
    //               ),
    //               _buildAchievementItem(
    //                 Icons.shield,
    //                 '5',
    //                 '5 Donations',
    //                 Colors.blueGrey,
    //               ),
    //               _buildAchievementItem(
    //                 Icons.healing,
    //                 '',
    //                 'Life Saver',
    //                 Colors.grey,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

  // Widget for a single achievement item
    // Widget _buildAchievementItem(
    //   IconData icon,
    //   String label,
    //   String subLabel,
    //   Color color,
    // ) {
    //   return Container(
    //     width: 100,
    //     margin: const EdgeInsets.only(right: 10),
    //     child: Column(
    //       children: [
    //         // Circular avatar for the achievement
    //         CircleAvatar(
    //           radius: 25,
    //           backgroundColor: color.withOpacity(0.2),
    //           child: Text(
    //             label,
    //             style: TextStyle(
    //               color: color,
    //               fontWeight: FontWeight.bold,
    //               fontSize: 18,
    //             ),
    //           ),
    //         ),
    //         const SizedBox(height: 5),
    //         // Text label below the avatar
    //         Text(
    //           subLabel,
    //           textAlign: TextAlign.center,
    //           style: const TextStyle(fontSize: 12),
    //         ),
    //       ],
    //     ),
    //   );
    // }

