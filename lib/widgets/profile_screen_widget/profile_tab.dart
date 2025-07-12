import 'package:flutter/material.dart';
import 'package:watch_hub_ep/services/profile_service.dart';

class BuildProfileTab extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController avatarController;
  final GlobalKey<FormState> formKey;

  const BuildProfileTab({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.avatarController,
    required this.formKey,
  });

  @override
  State<BuildProfileTab> createState() => _BuildProfileTabState();
}

class _BuildProfileTabState extends State<BuildProfileTab> {
  bool editing = false;
  final ProfileService _srv = ProfileService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: widget.avatarController.text.isNotEmpty
                      ? NetworkImage(widget.avatarController.text)
                      : const AssetImage('assets/images/default_user.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.nameController.text,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: Icon(editing ? Icons.cancel : Icons.edit),
                  onPressed: () => setState(() => editing = !editing),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: widget.nameController,
              enabled: editing,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.emailController,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.phoneController,
              enabled: editing,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.avatarController,
              enabled: editing,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 24),
            if (editing)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  onPressed: () {
                    if (widget.formKey.currentState!.validate()) {
                      _srv.updateProfile({
                        'fullName': widget.nameController.text.trim(),
                        'phone': widget.phoneController.text.trim(),
                        'avatarUrl': widget.avatarController.text.trim(),
                      });
                      setState(() => editing = false);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
