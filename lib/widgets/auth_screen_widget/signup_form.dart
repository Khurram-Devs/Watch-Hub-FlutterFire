import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _acceptedTerms = false;
  bool _isLoading = false;
  bool _googleLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate() || !_acceptedTerms) return;
    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _email.text.trim(),
            password: _password.text.trim(),
          );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(_name.text.trim());
        await FirebaseFirestore.instance
            .collection('usersProfile')
            .doc(user.uid)
            .set({
              'fullName': _name.text.trim(),
              'email': _email.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
            });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Signup successful!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed: ${e.toString()}')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _signupWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          setState(() => _googleLoading = false);
          return;
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }
      final user = userCredential.user;
      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('usersProfile')
                .doc(user.uid)
                .get();
        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('usersProfile')
              .doc(user.uid)
              .set({
                'fullName': user.displayName ?? '',
                'email': user.email ?? '',
                'createdAt': FieldValue.serverTimestamp(),
              });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-up successful!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-in failed: $e')));
    }
    setState(() => _googleLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator:
                (val) =>
                    val != null && val.length >= 2 ? null : 'Enter your name',
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
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
            decoration: const InputDecoration(labelText: 'Password'),
            validator:
                (val) =>
                    val != null && val.length >= 6 ? null : 'Min 6 characters',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: (_password.text.length / 12).clamp(0.0, 1.0),
            backgroundColor: theme.colorScheme.surface,
            color: theme.colorScheme.secondary,
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _acceptedTerms,
                onChanged:
                    (val) => setState(() => _acceptedTerms = val ?? false),
              ),
              const Expanded(child: Text("I agree to the Terms & Conditions")),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signup,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Sign Up"),
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
                  _googleLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text("Sign up with Google"),
              onPressed: _googleLoading ? null : _signupWithGoogle,
            ),
          ),
        ],
      ),
    );
  }
}
