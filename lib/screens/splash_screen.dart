import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/splash_watch.png',
                    width: screenWidth * 0.8,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    'SWISS',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: screenWidth * 0.06,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'LUXURY',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white60,
                      fontSize: screenWidth * 0.045,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'WATCHES',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.05,
            right: screenWidth * 0.07,
            child: IconButton(
              icon: Icon(Icons.arrow_forward, color: Colors.white, size: screenWidth * 0.08),
              onPressed: () {
                context.go('/home');
              },
            ),
          ),
        ],
      ),
    );
  }
}
