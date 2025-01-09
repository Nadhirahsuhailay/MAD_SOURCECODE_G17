import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymtrainer1/keys.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gymtrainer1/pages/login.dart';
import 'package:gymtrainer1/selectpackage.dart';
import 'package:intl/intl.dart';
import 'package:gymtrainer1/session_booking_page.dart';
import 'package:gymtrainer1/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _setup();
  runApp(const MyApp());
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = PublishableKey;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePageContent(),
      SessionBookingPage(),
      const ProfileScreen(),
      SettingsPage(),
    ];
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: _onNavBarItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String packageName = 'No Package';
  int sessionsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _fetchSessionData();
  }

  Future<void> _fetchSessionData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot packageDoc = await FirebaseFirestore.instance
          .collection('userPackages')
          .doc(userId)
          .get();

      if (packageDoc.exists) {
        setState(() {
          packageName = packageDoc['package'] ?? 'No Package';
          sessionsRemaining = packageDoc['sessionsRemaining'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching session data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> packages = [
      {
        'name': 'Package A',
        'description': '1 Training Session',
        'price': 'RM 2',
        'image': 'images/gb1.jpeg',
      },
      {
        'name': 'Package B',
        'description': '5 Training Sessions',
        'price': 'RM 3',
        'image': 'images/gb2.jpeg',
      },
      {
        'name': 'Package C',
        'description': '10 Training Sessions',
        'price': 'RM 135',
        'image': 'images/gb3.jpeg',
      },
    ];

    final List<Map<String, String>> trainingPrograms = [
      {'title': 'Main Core Workout', 'image': 'images/berat.jpg'},
      {'title': 'Beginner Set', 'image': 'images/dumbell.jpg'},
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/gr1.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.7), // Semi-transparent overlay
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Package: $packageName",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Sessions Remaining: $sessionsRemaining",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PackageSelectionScreen()),
                              );
                              _fetchSessionData(); // Refresh session data
                            },
                            child: const Text(
                              "Buy Session",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Packages Section
                    const Text(
                      "Packages",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: packages.map((package) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 120,
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: AssetImage(package['image']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  package['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  package['price'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Training Section
                    const Text(
                      "Training Programs",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: trainingPrograms.map((program) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 120,
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: AssetImage(program['image']!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  program['title']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}






class SessionBookingScreen extends StatefulWidget {
  @override
  _SessionBookingScreenState createState() => _SessionBookingScreenState();
} //stateful widget allow update content

class _SessionBookingScreenState extends State<SessionBookingScreen> {
  List<Map<String, dynamic>> sessions = [];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    // Determine the closest future date for the pending session
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> futureSessions =
        sessions.where((session) => session['date'].isAfter(now)).toList();
    futureSessions.sort((a, b) => a['date'].compareTo(b['date']));
    Map<String, dynamic>? pendingSession =
        futureSessions.isNotEmpty ? futureSessions.first : null;

    return Scaffold(
      //basic structure of the screen
      appBar: AppBar(
        title: Text(
          'Gym Trainer Booking',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Pending Session Section
          if (pendingSession != null)
            Container(
              color: Colors.grey[400],
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Session',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Date: ${DateFormat('dd MMMM yyyy').format(pendingSession['date'])}',
                      ),
                      Text('Remarks: ${pendingSession['remarks']}'),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        sessions.remove(pendingSession);
                      });
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

          // Sessions Section
          Expanded(
            child: ListView(
              children: [
                for (var session in sessions)
                  Container(
                    color: Colors.amber,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${DateFormat('dd MMMM yyyy').format(session['date'])}',
                            ),
                            Text('Remarks: ${session['remarks']}'),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              sessions.remove(session);
                            });
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSessionDialog(context),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _showAddSessionDialog(BuildContext context) {
    selectedDate = null;
    selectedTime = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(selectedDate == null
                  ? 'Select Date'
                  : DateFormat('dd MMMM yyyy').format(selectedDate!)),
            ),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
              child: Text(selectedTime == null
                  ? 'Select Time'
                  : selectedTime!.format(context)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedDate != null && selectedTime != null) {
                setState(() {
                  DateTime sessionDate = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  sessions.add({'date': sessionDate, 'remarks': ''});
                  sessions.sort((a, b) => a['date'].compareTo(b['date']));
                });
                Navigator.of(context).pop();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}



class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String username = 'Loading...';
  String height = 'Loading...';
  String weight = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['name'] ?? 'Unknown';
          height = userDoc['height'] ?? 'Unknown';
          weight = userDoc['weight'] ?? 'Unknown';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void handleEditProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Username'),
              controller: TextEditingController(text: username),
              onChanged: (value) {
                username = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              controller: TextEditingController(text: height),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                height = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              controller: TextEditingController(text: weight),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                weight = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              saveProfileDataToFirebase();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> saveProfileDataToFirebase() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': username,
        'height': height,
        'weight': weight,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  void handleChangePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
            'Are you sure you want to reset your password? A password reset email will be sent to your registered email address.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: FirebaseAuth.instance.currentUser!.email!,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset email sent!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void handleLogout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Replace with your actual login screen route
  }

  Widget buildSettingsOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/gr1.jpeg'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-Transparent Overlay
          Container(
            color: Colors.black.withOpacity(0.6), // Semi-transparent overlay
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Profile Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Height: $height cm',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Weight: $weight kg',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Settings Options
                  Expanded(
                    child: ListView(
                      children: [
                        buildSettingsOption(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          onTap: handleEditProfile,
                        ),
                        buildSettingsOption(
                          icon: Icons.lock,
                          title: 'Change Password',
                          onTap: handleChangePassword,
                        ),
                        buildSettingsOption(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: handleLogout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Loading...";
  String email = "Loading...";
  String weight = "Loading...";
  String height = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            name = userDoc.data()?['name'] ?? 'Unknown';
            email = user.email ?? 'Unknown';
            weight = userDoc.data()?['weight'] ?? 'Unknown';
            height = userDoc.data()?['height'] ?? 'Unknown';
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/gr1.jpeg'), // Set your image path here
                fit: BoxFit.cover, // Adjust the fit for the background
              ),
            ),
          ),
          // Content with semi-transparent background
          Container(
            color: Colors.black.withOpacity(0.6), // Semi-transparent overlay
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile picture
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30), // Spacing after profile picture

                // Profile fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          buildProfileField('Name', name),
                          buildProfileField('Email', email),
                          buildProfileField('Weight', "$weight kg"),
                          buildProfileField('Height', "$height cm"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Adjusted to match the dark background
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200]?.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


