import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gymtrainer1/pages/login.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Automatically navigate to the Login page after 3 seconds
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LogIn()),
        );
      });
    });

    return Scaffold(
      backgroundColor: Colors.black, // Set the background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'images/uniquepluslogo.png',
              width: 150, // Adjust as per your design
              height: 150,
            ),
            const SizedBox(height: 20), // Space between logo and text
            // App Name or Tagline
            const Text(
              "UniquePlus Gym Trainer",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Subtext or tagline
            const Text(
              "Your Fitness Journey Starts Here",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
