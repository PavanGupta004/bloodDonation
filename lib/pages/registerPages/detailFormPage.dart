import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//project-328892331271
//SHA1: F4:82:4C:1E:3F:EC:F8:B9:DD:2A:AC:D1:D7:51:02:37:86:B5:BC:97
//SHA-256: BC:27:AE:1B:74:5A:47:10:D2:2A:46:9A:10:01:22:B0:06:15:24:99:2E:C9:B0:F2:14:52:B9:79:7E:81:A2:D0
class DetailsFormPage extends StatefulWidget {
  final User user;
  const DetailsFormPage({super.key, required this.user});

  @override
  State<DetailsFormPage> createState() => _DetailsFormPageState();
}

class _DetailsFormPageState extends State<DetailsFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedType;
  String? _selectedGender;
  String? _selectedBloodType;

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
  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> userTypes = ['Hospital', 'NGO', 'Donor'];

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.user.email ?? "";
    _nameController.text = widget.user.displayName ?? "";
  }

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.uid)
          .set({
            "type": _selectedType,
            "name": _nameController.text.trim(),
            "dob": _dobController.text.trim(),
            "gender": _selectedGender,
            "location": _locationController.text.trim(),
            "bloodType": _selectedBloodType,
            "phone": _phoneController.text.trim(),
            "email": _emailController.text.trim(),
            "createdAt": DateTime.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details saved successfully ✅")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Your Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Type"),
                  value: _selectedType,
                  items: userTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedType = val),
                  validator: (val) =>
                      val == null ? "Please select a type" : null,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Name is required" : null,
                ),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: "Date of Birth (dd/MM/yyyy)",
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _dobController.text = DateFormat(
                        'dd/MM/yyyy',
                      ).format(picked);
                    }
                  },
                  validator: (val) =>
                      val == null || val.isEmpty ? "DOB required" : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Gender"),
                  value: _selectedGender,
                  items: genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedGender = val),
                  validator: (val) =>
                      val == null ? "Please select gender" : null,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Location required" : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Blood Type"),
                  value: _selectedBloodType,
                  items: bloodTypes
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBloodType = val),
                  validator: (val) =>
                      val == null ? "Please select blood type" : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Phone required";
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(val)) {
                      return "Enter valid 10-digit phone";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Email required";
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(val)) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveDetails,
                  child: const Text("Save Details"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
