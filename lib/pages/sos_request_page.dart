import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sos_blood_donation/database/data_requests.dart';
import 'package:sos_blood_donation/database/donor_service.dart';

class SOSRequestPage extends StatefulWidget {
  const SOSRequestPage({super.key});

  @override
  State<SOSRequestPage> createState() => _SOSRequestPageState();
}

class _SOSRequestPageState extends State<SOSRequestPage> {
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  String? selectedBloodGroup;
  String? selectedLocation;
  String selectedUrgency = 'Immediate';
  int quantity = 1;
  final RequestData _dataRequest = RequestData();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    selectedBloodGroup = null;
    selectedLocation = null;
    selectedUrgency = 'Immediate';
    quantity = 1;
  }

  Future<void> submitRequest() async {
    if (selectedBloodGroup == null ||
        selectedLocation == null ||
        selectedLocation!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      // Dummy coordinates for now, replace with geocoding later
      double latitude = 12.9716; // Example: Bangalore
      double longitude = 77.5946;

      // 1️⃣ Save request and get requestId
      final docRef = await FirebaseFirestore.instance
          .collection("requests")
          .add({
            "bloodType": selectedBloodGroup,
            "location": GeoPoint(latitude, longitude),
            "urgency": selectedUrgency,
            "quantity": quantity,
            "requestDateTime": FieldValue.serverTimestamp(),
            "requestFulfilled": false,
          });

      print("✅ Request saved with ID: ${docRef.id}");

      // 2️⃣ Find nearby donors
      final donorService = DonorService();
      List<Map<String, dynamic>> donors = await donorService.findNearbyDonors(
        docRef.id,
        10,
      ); // 10 km range

      if (donors.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No nearby donors found')));
      } else {
        for (var donor in donors) {
          print(
            "📍 Donor: ${donor['name']} | ${donor['distanceKm'].toStringAsFixed(2)} km | Phone: ${donor['phone']}",
          );

          // 3️⃣ Example: open SMS app (needs url_launcher)
          // await launchUrl(Uri.parse(
          //   "sms:${donor['phone']}?body=Urgent! Blood $selectedBloodGroup needed at $selectedLocation. Please help if possible.",
          // ));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${donors.length} nearby donors found')),
        );
      }

      // 4️⃣ Optionally clear form & pop page
      setState(() {
        selectedBloodGroup = null;
        selectedLocation = null;
        selectedUrgency = 'Immediate';
        quantity = 1;
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit request: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo and title
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bloodtype_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'REQUEST BLOOD DONATION\nCARE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Request Blood Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              // Blood Group Selection
              const Text(
                'Required Blood Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: selectedBloodGroup,
                  isExpanded: true,
                  hint: const Center(
                    child: Text(
                      'Select Blood Group',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.red),
                  underline: Container(),
                  items: bloodTypes.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedBloodGroup = newValue;
                      print('Blood Group changed to: $selectedBloodGroup');
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Location Input
              const Text(
                'Patient Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  textAlign: TextAlign.center, // Add this
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                      print('Location changed to: $selectedLocation');
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Hospital/Clinic & City',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    prefixIcon: const Padding(
                      // Wrap icon in Padding
                      padding: EdgeInsets.only(left: 15),
                      child: Icon(Icons.location_on, color: Colors.red),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Urgency Level Selection
              const Text(
                'Urgency Level',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildUrgencyButton(
                    'Immediate',
                    selectedUrgency == 'Immediate',
                  ),
                  const SizedBox(width: 10),
                  _buildUrgencyButton('Urgent', selectedUrgency == 'Urgent'),
                  const SizedBox(width: 10),
                  _buildUrgencyButton(
                    'Standard',
                    selectedUrgency == 'Standard',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Quantity Selection
              const Text(
                'Quantity (units)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.red),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                            print('Quantity decreased to: $quantity');
                          });
                        }
                      },
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.red),
                      onPressed: () => setState(() {
                        quantity++;
                        print('Quantity increased to: $quantity');
                      }),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'SUBMIT REQUEST',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          selectedUrgency = text;
          print('Urgency Level changed to: $selectedUrgency');
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.red.shade800 : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.red.shade800 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
