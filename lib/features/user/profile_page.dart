import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../constants/appRouter_constants.dart';
import '../../constants/firebase_collections.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  User? _user;
  Map<String, dynamic>? _firestoreUserData;
  bool _isLoading = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _phoneController;

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;

  Position? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    _nameController = TextEditingController(text: _user?.displayName ?? '');
    _addressController = TextEditingController();
    _landmarkController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _pincodeController = TextEditingController();
    _phoneController = TextEditingController();

    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      setState(() => _isLoading = true);
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(_user!.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _firestoreUserData = doc.data();
          _addressController.text = _firestoreUserData?['address'] ?? '';
          _landmarkController.text = _firestoreUserData?['landmark'] ?? '';
          _cityController.text = _firestoreUserData?['city'] ?? '';
          _stateController.text = _firestoreUserData?['state'] ?? '';
          _pincodeController.text = _firestoreUserData?['pincode'] ?? '';
          final phoneFromDb = _firestoreUserData?['phone'] ?? '';
          if (phoneFromDb.startsWith('+91')) {
            _phoneController.text = phoneFromDb.substring(3);
          }
          if (_firestoreUserData?['location'] != null) {
            _pickedLocation = Position(
              latitude: _firestoreUserData!['location']['lat'],
              longitude: _firestoreUserData!['location']['lng'],
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0,
            );
          }
        });
      }
      setState(() => _isLoading = false);
    }
  }

  String _getInitials(String? displayName, String? email) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(' ').map((s) => s[0]).join().toUpperCase();
    } else if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImageName = pickedFile.name;
        });
      } else {
        setState(() {
          _pickedImageBytes = File(pickedFile.path).readAsBytesSync();
          _pickedImageName = pickedFile.path.split('/').last;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedImageBytes == null || _user == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${_user!.uid}_${_pickedImageName ?? "profile"}.jpg');

      await storageRef.putData(
        _pickedImageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await storageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint('Upload failed: ${e.message}');
      return null;
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    );
  }

  Future<void> _fillAddressFromLocation() async {
    try {
      Position position = await _getCurrentLocation();
      _pickedLocation = position;

      if (kIsWeb) {
        final url = Uri.parse(
          "https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json",
        );
        final response = await http.get(
          url,
          headers: {"User-Agent": "FlutterApp"},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data["address"] ?? {};

          setState(() {
            _addressController.text = data["display_name"] ?? '';
            _landmarkController.text = address["suburb"] ?? '';
            _cityController.text =
                address["city"] ?? address["town"] ?? address["village"] ?? '';
            _stateController.text = address["state"] ?? '';
            _pincodeController.text = address["postcode"] ?? '';
          });
        } else {
          throw Exception("Failed to fetch address from OSM");
        }
      } else {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _addressController.text = place.thoroughfare ?? '';
            _landmarkController.text = place.subLocality ?? '';
            _cityController.text = place.locality ?? '';
            _stateController.text = place.administrativeArea ?? '';
            _pincodeController.text = place.postalCode ?? '';
          });
        }
      }
    } catch (e, st) {
      debugPrint("Error fetching location: $e");
      debugPrintStack(stackTrace: st);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unable to fetch location")));
    }
  }

  double _calculateProfileCompletion() {
    int filledFields = 0;
    int totalFields = 7;
    if (_nameController.text.isNotEmpty) filledFields++;
    if (_addressController.text.isNotEmpty) filledFields++;
    if (_landmarkController.text.isNotEmpty) filledFields++;
    if (_cityController.text.isNotEmpty) filledFields++;
    if (_stateController.text.isNotEmpty) filledFields++;
    if (_pincodeController.text.isNotEmpty) filledFields++;
    if (_phoneController.text.isNotEmpty) filledFields++;

    return filledFields / totalFields;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String? photoURL = _user!.photoURL;
      if (_pickedImageBytes != null) {
        photoURL = await _uploadImage();
      }

      if (_user != null) {
        await _user!.updateDisplayName(_nameController.text);
        if (photoURL != null) await _user!.updatePhotoURL(photoURL);
      }

      String? phone;
      if (_phoneController.text.isNotEmpty) {
        phone = "+91${_phoneController.text.trim()}";
      }

      await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(_user!.uid)
          .set({
            'name': _nameController.text,
            'address': _addressController.text,
            'landmark': _landmarkController.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'pincode': _pincodeController.text,
            'phone': phone,
            'photoURL': photoURL,
            'location': _pickedLocation != null
                ? {
                    'lat': _pickedLocation!.latitude,
                    'lng': _pickedLocation!.longitude,
                  }
                : null,
          }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final String? currentPhotoURL =
        _user?.photoURL ?? _firestoreUserData?['photoURL'];
    final String? currentDisplayName =
        _user?.displayName ?? _firestoreUserData?['name'];
    final String? currentEmail = _user?.email;

    final profileCompletion = _calculateProfileCompletion();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (shouldSignOut == true) {
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text("Save"),
            ),
      body: _isLoading && _firestoreUserData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture with glow
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: currentPhotoURL != null
                              ? NetworkImage(currentPhotoURL)
                              : null,
                          child: currentPhotoURL == null
                              ? Text(
                                  _getInitials(
                                    currentDisplayName,
                                    currentEmail,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile Completion
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Profile Completion: ${(profileCompletion * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: profileCompletion,
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(8),
                              color: profileCompletion >= 1.0
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact Info
                    _sectionTitle("Contact Info"),
                    _buildTextField(
                      _nameController,
                      "Name",
                      Icons.person,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Enter name" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      readOnly: true,
                      initialValue: _user?.email ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixText: '+91 ',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter phone number";
                        }
                        final regex = RegExp(r'^[6-9]\d{9}$');
                        if (!regex.hasMatch(value)) {
                          return "Enter valid Indian number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Address Info
                    _sectionTitle("Address Info"),
                    TextFormField(
                      controller: _addressController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Enter address" : null,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _fillAddressFromLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text("Use Current Location"),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _landmarkController,
                      "Landmark (optional)",
                      Icons.place_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _cityController,
                      "City",
                      Icons.location_city,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _stateController,
                      "State",
                      Icons.map_outlined,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Pincode',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pin_drop_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter pincode";
                        }
                        if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                          return "Enter valid 6-digit pincode";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 80), // for FAB spacing
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
