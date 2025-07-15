import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:watch_hub_ep/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _acceptedTerms = false;
  bool _isLoading = false;
  bool _googleLoading = false;
  bool _showPassword = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate() || !_acceptedTerms) return;

    if (!mounted) return; // <== Just in case
    setState(() => _isLoading = true);

    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        _email.text.trim(),
      );

      if (methods.isNotEmpty) {
        throw FirebaseAuthException(code: 'email-already-in-use');
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _email.text.trim(),
            password: _password.text.trim(),
          );

      final user = credential.user;
      final fullName = '${_firstName.text.trim()} ${_lastName.text.trim()}';

      if (user != null) {
        await user.updateDisplayName(fullName);
        await FirebaseFirestore.instance
            .collection('usersProfile')
            .doc(user.uid)
            .set({
              'fullName': fullName,
              'firstName': _firstName.text.trim(),
              'lastName': _lastName.text.trim(),
              'email': _email.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
            });

        if (!mounted) return; // ← Check before using context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successful! Please login to continue'),
          ),
        );

        context.push('/auth/login');
      }
    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseErrorMessage(e.code);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signupWithGoogle() async {
    if (!mounted) return;
    setState(() => _googleLoading = true);

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }

      final user = userCredential.user; // ✅ ADD THIS LINE

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

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-up successful!')),
        );

        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseErrorMessage(e.code);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-in failed. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'An error occurred: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("Create Account", style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator:
                        (val) =>
                            val != null && val.trim().isNotEmpty
                                ? null
                                : 'Enter your first name',
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator:
                        (val) =>
                            val != null && val.trim().isNotEmpty
                                ? null
                                : 'Enter your last name',
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _email,
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
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed:
                            () =>
                                setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    validator:
                        (val) =>
                            val != null && val.length >= 6
                                ? null
                                : 'Minimum 6 characters',
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
                            (val) =>
                                setState(() => _acceptedTerms = val ?? false),
                      ),
                      const Expanded(
                        child: Text("I agree to the Terms & Conditions"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text("Sign Up"),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text("OR"),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata_outlined, size: 28),
                      label:
                          _googleLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text("Sign up with Google"),
                      onPressed: _googleLoading ? null : _signupWithGoogle,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      TextButton(
                        onPressed: () => context.push('/auth/login'),
                        child: const Text("Log in"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
