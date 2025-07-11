import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './auth_screen.dart';

class RedirectAuthScreen extends StatelessWidget {
  const RedirectAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Future.microtask(() {
        context.go('/home');
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const AuthScreen();
  }
}
