import 'dart:async';
import 'package:flutter/material.dart';
import 'package:watch_hub_ep/models/user_model.dart';
import 'package:watch_hub_ep/services/profile_service.dart';
import 'package:watch_hub_ep/widgets/layout_widget/app_header.dart';
import 'package:watch_hub_ep/widgets/layout_widget/nav_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  final _nameController = TextEditingController();
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
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _avatarController.text = user.avatar;
      });
    });
  }

  @override
  void dispose() {
    _profileSub.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AppHeader(),
      drawer: const NavDrawer(),
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
                          backgroundImage: _avatarController.text.isNotEmpty
                              ? NetworkImage(_avatarController.text)
                              : const AssetImage('assets/images/default_user.png') as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _nameController.text,
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
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      enabled: _editing,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Email'),
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
                      enabled: _editing,
                      decoration: const InputDecoration(labelText: 'Avatar URL'),
                      onChanged: (_) => setState(() {}),
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
                                'fullName': _nameController.text.trim(),
                                'phone': _phoneController.text.trim(),
                                'avatarUrl': _avatarController.text.trim(),
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
