import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/data_requests.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final RequestData _requestData = RequestData();
  final String? userUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Donated'),
              Tab(text: 'Requested'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Donated History Tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: userUid != null
                  ? _requestData.getDonatedHistory(userUid!)
                  : Future.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final history = snapshot.data ?? [];
                if (history.isEmpty) {
                  return const Center(child: Text('No donated history found.'));
                }
                return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      title: Text('Blood Type: ${item['bloodType'] ?? 'N/A'}'),
                      subtitle: Text('Quantity: ${item['quantity'] ?? 'N/A'}'),
                      trailing: Text(
                        item['requestFulfilledAt']?.toDate().toString() ?? '',
                      ),
                    );
                  },
                );
              },
            ),
            // Requested History Tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: userUid != null
                  ? _requestData.getRequestedHistory(userUid!)
                  : Future.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final history = snapshot.data ?? [];
                if (history.isEmpty) {
                  return const Center(
                    child: Text('No requested history found.'),
                  );
                }
                return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      title: Text('Blood Type: ${item['bloodType'] ?? 'N/A'}'),
                      subtitle: Text('Quantity: ${item['quantity'] ?? 'N/A'}'),
                      trailing: Text(
                        item['requestDateTime']?.toDate().toString() ?? '',
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
