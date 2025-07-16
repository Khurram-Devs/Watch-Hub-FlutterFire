import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:watch_hub_ep/models/user_model.dart';
import 'package:watch_hub_ep/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _occupationController = TextEditingController();
  String _avatarUrl = '';

  bool _editing = false;
  late final StreamSubscription _profileSub;

  @override
  void initState() {
    super.initState();
    _profileSub = _profileService.profileStream().listen((doc) {
      if (!doc.exists || !mounted) return;
      final user = UserModel.fromDoc(doc);
      setState(() {
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _occupationController.text = user.occupation ?? '';
        _avatarUrl = user.avatar;
      });
    });
  }

  @override
  void dispose() {
    _profileSub.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    if (picked != null && picked.files.single.bytes != null) {
      final bytes = picked.files.single.bytes!;
      final name = picked.files.single.name;

      final uri = Uri.parse(
        "https://api.imgbb.com/1/upload?key=35e23c1d07b073e59906736c89bb77c5",
      );

      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes('image', bytes, filename: name),
        );

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (data['success'] == true) {
        setState(() => _avatarUrl = data['data']['url']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avatar updated successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload avatar.")),
        );
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.contains('@')) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      if (_editing)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final firstName =
                                  _firstNameController.text.trim();
                              final lastName = _lastNameController.text.trim();
                              final fullName = "$firstName $lastName";

                              _profileService.updateProfile({
                                'firstName': firstName,
                                'lastName': lastName,
                                'fullName': fullName,
                                'phone': _phoneController.text.trim(),
                                'occupation': _occupationController.text.trim(),
                                'avatarUrl': _avatarUrl,
                              });

                              setState(() => _editing = false);
                            }
                          },
                        ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: Icon(_editing ? Icons.cancel : Icons.edit),
                        label: Text(_editing ? "Cancel" : "Edit"),
                        onPressed: () {
                          setState(() => _editing = !_editing);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _avatarUrl.isNotEmpty
                              ? NetworkImage(_avatarUrl)
                              : const AssetImage(
                                    'assets/images/default_user.png',
                                  )
                                  as ImageProvider,
                    ),
                    if (_editing)
                      IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.black87,
                        ),
                        onPressed: _pickAndUploadImage,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // First/Last Name
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            enabled: _editing,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            enabled: _editing,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      enabled: _editing,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 16),

                    // Occupation
                    TextFormField(
                      controller: _occupationController,
                      enabled: _editing,
                      decoration: const InputDecoration(
                        labelText: 'Occupation',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email (always disabled)
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _sendPasswordReset,
                        child: const Text("Forgot Password?"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
