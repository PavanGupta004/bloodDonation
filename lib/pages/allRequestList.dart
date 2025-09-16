import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

import 'package:sos_blood_donation/pages/sos_view_details.dart';

class RequestsPage extends StatefulWidget {
  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  String? username;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {});
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Fetch all requests with user details
  Future<List<Map<String, dynamic>>> fetchAllRequests() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('requests')
          .orderBy('requestDateTime', descending: true) // Recent first
          .get();

      List<Map<String, dynamic>> requestsWithUserData = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> requestData = doc.data() as Map<String, dynamic>;
        requestData['id'] = doc.id;

        String userId = requestData['requestFrom'] ?? '';
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          username =
              (userDoc.data() as Map<String, dynamic>?)?['name'] ??
              'Unknown User';
        } catch (e) {
          username = 'Unknown User';
        }

        // Get user name from users collection
        if (userId.isNotEmpty) {
          try {
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

            if (userDoc.exists) {
              Map<String, dynamic> userData =
                  userDoc.data() as Map<String, dynamic>;
              requestData['userName'] = userData['name'] ?? 'Unknown User';
            } else {
              requestData['userName'] = 'Unknown User';
            }
          } catch (e) {
            requestData['userName'] = 'Unknown User';
            print('Error fetching user data: $e');
          }
        } else {
          requestData['userName'] = 'Unknown User';
        }

        // Calculate distance if current location is available
        if (currentPosition != null && requestData['location'] != null) {
          GeoPoint requestLocation = requestData['location'];
          double distance = _calculateDistance(
            currentPosition!.latitude,
            currentPosition!.longitude,
            requestLocation.latitude,
            requestLocation.longitude,
          );
          requestData['distanceKm'] = distance;
        } else {
          requestData['distanceKm'] = null;
        }

        requestsWithUserData.add(requestData);
      }

      return requestsWithUserData;
    } catch (e) {
      print('Error fetching requests: $e');
      return [];
    }
  }

  // Calculate distance using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371; // Earth radius in km
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // Get urgency color and priority
  Map<String, dynamic> _getUrgencyInfo(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'Immediate':
      case 'high':
        return {'color': Colors.red, 'priority': 3};
      case 'medium':
      case 'Urgent':
        return {'color': Colors.orange, 'priority': 2};
      case 'low':
      case 'Standard':
        return {'color': Colors.yellow[700], 'priority': 1};
      default:
        return {'color': Colors.grey, 'priority': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Requests'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              _getCurrentLocation();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllRequests(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 16),
                  Text('Loading requests...'),
                ],
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Data loaded
          List<Map<String, dynamic>> requests = snapshot.data ?? [];

          // Empty state
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No requests found'),
                ],
              ),
            );
          }

          // Display requests in cards
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final urgencyInfo = _getUrgencyInfo(
                request['urgencyLevel'] ?? '',
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SOSViewDetailsPage(requestId: request['requestId']),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Blood type and patient name
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    request['bloodType'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    username ?? 'Loading...',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 60), // Space for urgency banner
                              ],
                            ),
                            SizedBox(height: 8),

                            // Distance
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  request['distanceKm'] != null
                                      ? '${request['distanceKm']!.toStringAsFixed(1)} km away'
                                      : 'Distance unavailable',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),

                            // Units needed
                            Row(
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  color: Colors.red[400],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Units needed: ${request['quantity'] ?? 1}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),

                            // Status
                            Row(
                              children: [
                                Icon(
                                  request['requestFulfilled'] == true
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  color: request['requestFulfilled'] == true
                                      ? Colors.green
                                      : Colors.orange,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  request['requestFulfilled'] == true
                                      ? 'Fulfilled'
                                      : 'Active',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: request['requestFulfilled'] == true
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Request time
                            if (request['requestDateTime'] != null) ...[
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    _getTimeAgo(request['requestDateTime']),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Urgency banner on the right side
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: urgencyInfo['color'],
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              (request['urgencyLevel'] ?? 'Normal')
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper function to get time ago
  String _getTimeAgo(dynamic timestamp) {
    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else {
        return 'Unknown time';
      }

      Duration difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}
