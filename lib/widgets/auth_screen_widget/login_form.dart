import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
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

      if (mounted) {
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseErrorMessage(e.code);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
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

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-in failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Login error: $code';
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
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator:
                (val) =>
                    val != null && val.contains('@')
                        ? null
                        : 'Enter a valid email',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator:
                (val) =>
                    val != null && val.length >= 6
                        ? null
                        : 'Password must be at least 6 characters',
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
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
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
              label:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text("Login with Google"),
              onPressed: _isLoading ? null : _loginWithGoogle,
            ),
          ),
        ],
      ),
    );
  }
}
