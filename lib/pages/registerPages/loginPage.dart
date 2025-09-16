import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Dropdown values
  String? _selectedType;
  String? _selectedGender;
  String? _selectedBloodType;

  // Blood type options
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
  final List<String> userTypes = ['Hospital', 'NGO', 'Donor/Requester'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registration Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Type
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

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Name is required";
                    }
                    if (val.length < 3) {
                      return "Name must be at least 3 characters";
                    }
                    return null;
                  },
                ),

                // DOB
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: "Date of Birth (dd/MM/yyyy)",
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      _dobController.text = DateFormat(
                        'dd/MM/yyyy',
                      ).format(pickedDate);
                    }
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Date of Birth is required";
                    }
                    return null;
                  },
                ),

                // Gender
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Gender"),
                  value: _selectedGender,
                  items: genders
                      .map(
                        (gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedGender = val),
                  validator: (val) =>
                      val == null ? "Please select gender" : null,
                ),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                  validator: (val) => val == null || val.isEmpty
                      ? "Location is required"
                      : null,
                ),

                // Blood Type
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Blood Type"),
                  value: _selectedBloodType,
                  items: bloodTypes
                      .map(
                        (blood) =>
                            DropdownMenuItem(value: blood, child: Text(blood)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBloodType = val),
                  validator: (val) =>
                      val == null ? "Please select blood type" : null,
                ),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Phone number is required";
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(val)) {
                      return "Enter valid 10-digit phone number";
                    }
                    return null;
                  },
                ),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Email is required";
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(val)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Form Submitted ✅")),
                      );
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
