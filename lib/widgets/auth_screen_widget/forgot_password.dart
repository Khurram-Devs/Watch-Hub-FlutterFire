import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  final _email = TextEditingController();
  bool _sent = false;
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    setState(() {
      _isLoading = true;
      _sent = false;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _email.text.trim(),
      );
      setState(() => _sent = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Enter your email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendResetLink,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text("Send Reset Link"),
          ),
        ),
        if (_sent) const Text("Password reset link sent. Check your inbox."),
      ],
    );
  }
}
