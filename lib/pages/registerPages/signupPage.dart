import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sos_blood_donation/pages/home_page.dart';
import 'package:sos_blood_donation/services/auth_services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedType;
  String? _selectedGender;
  String? _selectedBloodType;

  final List<String> userTypes = ['Hospital', 'NGO', 'Donor/Requester'];
  final List<String> genders = ['Male', 'Female', 'Other'];
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

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  double? _latitude;
  double? _longitude;

  Future<void> _fetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permissions are permanently denied."),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationController.text = "${position.latitude}, ${position.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // User Type
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Type"),
                        value: _selectedType,
                        items: userTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _selectedType = val),
                        validator: (val) =>
                            val == null ? "Please select type" : null,
                      ),
                      const SizedBox(height: 10),

                      // Only for Donor/Requester
                      if (_selectedType == 'Donor/Requester') ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: "Name"),
                          validator: (val) => val == null || val.isEmpty
                              ? "Name required"
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Date of Birth",
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              _dobController.text =
                                  "${picked.day}/${picked.month}/${picked.year}";
                            }
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? "DOB required"
                              : null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "Gender",
                          ),
                          value: _selectedGender,
                          items: genders
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedGender = val),
                          validator: (val) =>
                              val == null ? "Gender required" : null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "Blood Type",
                          ),
                          value: _selectedBloodType,
                          items: bloodTypes
                              .map(
                                (b) =>
                                    DropdownMenuItem(value: b, child: Text(b)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedBloodType = val),
                          validator: (val) =>
                              val == null ? "Blood type required" : null,
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Common fields
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: "Phone"),
                        validator: (val) => val == null || val.isEmpty
                            ? "Phone required"
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: "Email"),
                        validator: (val) => val == null || val.isEmpty
                            ? "Email required"
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? "Password required"
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _locationController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Location",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.my_location),
                            onPressed: _fetchLocation,
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? "Location required"
                            : null,
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () async {
                          CircularProgressIndicator();
                          if (_formKey.currentState!.validate()) {
                            if (_latitude == null || _longitude == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Fetch your location"),
                                ),
                              );
                              return;
                            }
                            setState(() => _isLoading = true);

                            final user = await _authService
                                .createUserWithEmailAndData(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  name: _nameController.text.trim(),
                                  dob: _dobController.text.trim(),
                                  gender: _selectedGender ?? "",
                                  bloodType: _selectedBloodType ?? "",
                                  phone: _phoneController.text.trim(),
                                  type: _selectedType ?? "",
                                  latitude: _latitude!,
                                  longitude: _longitude!,
                                );

                            setState(() => _isLoading = false);
                            Navigator.pop(context);

                            if (user != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Registration Successful ✅"),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomePage(),
                                ),
                              );

                              // Navigate to HomePage
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Registration Failed ❌"),
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
