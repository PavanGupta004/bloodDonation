import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sos_blood_donation/pages/home_page.dart';
import 'package:sos_blood_donation/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // new

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
                      _dobController.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
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

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Password is required";
                    }
                    if (val.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      User? user = await _authService
                          .createUserWithEmailAndData(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            userType: _selectedType!,
                            name: _nameController.text.trim(),
                            dob: _dobController.text.trim(),
                            gender: _selectedGender!,
                            location: _locationController.text.trim(),
                            bloodType: _selectedBloodType!,
                            phone: _phoneController.text.trim(),
                          );

                      if (user != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Registration Successful ✅"),
                          ),
                        );

                        // Navigate to HomePage or dashboard
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Registration failed. Try again."),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
