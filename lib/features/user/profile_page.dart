import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: _user?.displayName ?? '');
    _bioController = TextEditingController();
    _fetchFirestoreUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _fetchFirestoreUserData() async {
    if (_user != null) {
      setState(() {
        _isLoading = true;
      });
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _firestoreUserData = doc.data();
          _bioController.text = _firestoreUserData?['bio'] ?? '';
        });
      }
      setState(() {
        _isLoading = false;
      });
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
        // On web, read as bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImageName = pickedFile.name; // use name for storage
        });
      } else {
        // On mobile, use File
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      String? photoURL = _user!.photoURL;
      if (_pickedImage != null) {
        photoURL = await _uploadImage();
      }
      if (_user != null) {
        await _user!.updateDisplayName(_nameController.text);
        if (photoURL != null) {
          await _user!.updatePhotoURL(photoURL);
        }
      }
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'name': _nameController.text,
        'bio': _bioController.text,
        'photoURL': photoURL,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? currentPhotoURL = _pickedImage != null
        ? null
        : (_user?.photoURL ?? _firestoreUserData?['photoURL']);
    final String? currentDisplayName =
        _user?.displayName ?? _firestoreUserData?['name'];
    final String? currentEmail = _user?.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _isLoading && _firestoreUserData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (currentPhotoURL != null
                                          ? NetworkImage(currentPhotoURL)
                                          : null)
                                      as ImageProvider?,
                            child:
                                _pickedImage == null && currentPhotoURL == null
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
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      initialValue: _user?.email ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      initialValue: _firestoreUserData!['role'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _saveProfile,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Profile'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
