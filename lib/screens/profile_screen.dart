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
  final _avatarController = TextEditingController();

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
        _avatarController.text = user.avatar;
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
    _avatarController.dispose();
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
        final url = data['data']['url'];
        setState(() => _avatarController.text = url);
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              _avatarController.text.isNotEmpty
                                  ? NetworkImage(_avatarController.text)
                                  : const AssetImage(
                                        'assets/images/default_user.png',
                                      )
                                      as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "${_firstNameController.text} ${_lastNameController.text}",
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          icon: Icon(_editing ? Icons.cancel : Icons.edit),
                          onPressed: () {
                            setState(() => _editing = !_editing);
                          },
                        ),
                      ],
                    ),
                    if (_editing)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _pickAndUploadImage,
                          icon: const Icon(Icons.upload),
                          label: const Text("Change Avatar"),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // First & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email & Forgot Password
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _sendPasswordReset,
                          child: const Text("Forgot Password?"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      enabled: _editing,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _avatarController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Avatar URL',
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_editing)
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _profileService.updateProfile({
                                'phone': _phoneController.text.trim(),
                                'avatar': _avatarController.text.trim(),
                              });
                              setState(() => _editing = false);
                            }
                          },
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
