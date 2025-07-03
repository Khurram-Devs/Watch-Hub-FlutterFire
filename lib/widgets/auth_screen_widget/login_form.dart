import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginForm extends StatefulWidget {
  final void Function() onForgotPassword;
  const LoginForm({super.key, required this.onForgotPassword});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }

    setState(() => _isLoading = false);
  }

Future<void> _loginWithGoogle() async {
  try {
    if (kIsWeb) {
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google Sign-in Success')),
    );
    } else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google Sign-in failed: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (val) =>
                val != null && val.contains('@') ? null : 'Enter a valid email',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (val) =>
                val != null && val.length >= 6 ? null : 'Min 6 characters',
          ),
          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              child: const Text("Forgot Password?"),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),
          ),

          const SizedBox(height: 16),
          const Text("OR"),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text("Login with Google"),
              onPressed: _loginWithGoogle,
            ),
          ),
        ],
      ),
    );
  }
}
