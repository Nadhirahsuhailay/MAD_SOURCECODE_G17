import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymtrainer1/services/stripe_service.dart';

class PackageSelectionScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Choose Your Package',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Image.asset(
            'images/gr1.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1 Session = 1 Hour 30 minutes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select the package that best suits your needs:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      PackageCard(
                        imagePath: 'images/gb1.jpeg',
                        description: '1 Training Session',
                        price: 'RM 2',
                        packageName: 'Package A',
                        packageSessions: 1,
                        packagePrice: 2,
                        onPressed: () =>
                            _makePayment(context, 2, 'Package A', 1),
                      ),
                      const SizedBox(height: 20),
                      PackageCard(
                        imagePath: 'images/gb2.jpeg',
                        description: '5 Training Sessions',
                        price: 'RM 3',
                        packageName: 'Package B',
                        packageSessions: 5,
                        packagePrice: 3,
                        onPressed: () =>
                            _makePayment(context, 3, 'Package B', 5),
                      ),
                      const SizedBox(height: 20),
                      PackageCard(
                        imagePath: 'images/gb3.jpeg',
                        description: '10 Training Sessions',
                        price: 'RM 135',
                        packageName: 'Package C',
                        packageSessions: 10,
                        packagePrice: 135,
                        onPressed: () =>
                            _makePayment(context, 135, 'Package C', 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePayment(BuildContext context, int price, String packageName,
      int sessions) async {
    try {
      bool success = await StripeService.instance.makePayment(price, "RM $price");

      if (success) {
        await _updatePackageInFirestore(packageName, sessions);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Package added to your account.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error during payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updatePackageInFirestore(
      String packageName, int sessions) async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentReference userPackageRef =
          _firestore.collection('userPackages').doc(userId);

      DocumentSnapshot packageSnapshot = await userPackageRef.get();
      if (packageSnapshot.exists) {
        // Update existing package
        int currentSessions =
            packageSnapshot['sessionsRemaining'] ?? 0; // Default to 0 if null
        await userPackageRef.update({
          'package': packageName,
          'sessionsRemaining': currentSessions + sessions,
        });
      } else {
        // Create new package
        await userPackageRef.set({
          'package': packageName,
          'sessionsRemaining': sessions,
        });
      }
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }
}

class PackageCard extends StatelessWidget {
  final String imagePath;
  final String description;
  final String price;
  final String packageName;
  final int packageSessions;
  final int packagePrice;
  final VoidCallback onPressed;

  const PackageCard({
    required this.imagePath,
    required this.description,
    required this.price,
    required this.packageName,
    required this.packageSessions,
    required this.packagePrice,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            packageName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Price: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onPressed,
                child: const Text(
                  'Get',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
