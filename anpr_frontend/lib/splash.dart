import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add Google Fonts for typography
import 'package:lottie/lottie.dart'; // Lottie animations

import 'home.dart'; // Import the home page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final int splashDelay = 4; // Set the splash delay

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: splashDelay), navigateToHome);
  }

  void navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MyHomePage(title: 'ANPR Home'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Center(
        // Center the content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Title text for the splash screen
            Text(
              "Automatic License Plate Recognition",
              style: GoogleFonts.poppins(
                fontSize: 30, // Adjusted font size
                color: Colors.deepPurple, // Deep purple text color
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Container to increase width for the animations
            Container(
              width: MediaQuery.of(context).size.width *
                  0.8, // 80% of screen width
              height: 450, // Set a specific height to the container
              child: Stack(
                alignment: Alignment.center, // Center align the animations
                children: [
                  // CCTV animation (cam-cctv.json) positioned at the top left
                  Positioned(
                    top: 20, // Adjusted top position to ensure visibility
                    left: MediaQuery.of(context).size.width *
                        0.1, // Position CCTV more to the left
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.2, // Width relative to screen size
                      child: Lottie.asset(
                        'assets/gif/cam-cctv.json',
                        height: 80, // Height of the camera animation
                      ),
                    ),
                  ),

                  // Car animation (fast-furious.json) made bigger and moved up
                  Positioned(
                    top: 30, // Moved car animation further up
                    child: Lottie.asset(
                      'assets/gif/fast-furious.json',
                      height: 400, // Increased size for the car animation
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Circular progress indicator
            CircularProgressIndicator(
              color: Colors.deepPurple, // Deep purple progress indicator
            ),
          ],
        ),
      ),
    );
  }
}
