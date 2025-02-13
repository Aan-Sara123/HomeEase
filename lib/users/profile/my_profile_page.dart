import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _imageFile;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      setState(() {
        _profileImageUrl = data['photoUrl'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    String? imageUrl = _profileImageUrl;

    try {
      if (_imageFile != null) {
        imageUrl = await _uploadProfileImage(_imageFile!);
      }

      await _firestore.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'photoUrl': imageUrl ?? "",
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() => _profileImageUrl = imageUrl ?? "");

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Profile Updated")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                        : const AssetImage('assets/default_avatar.png')),
                child: _imageFile == null &&
                        (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                    ? const Icon(Icons.camera_alt,
                        size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
