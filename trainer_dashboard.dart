import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gymtrainer1/pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrainerHomePage(),
    );
  }
}

class TrainerHomePage extends StatefulWidget {
  const TrainerHomePage({Key? key}) : super(key: key);

  @override
  _TrainerHomePageState createState() => _TrainerHomePageState();
}

class _TrainerHomePageState extends State<TrainerHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
     TrainerDashboard(),
     TrainerSchedule(),
    TrainerProfile(),
  ];

  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        onTap: _onNavBarItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class TrainerDashboard extends StatelessWidget {
  const TrainerDashboard({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> _fetchTrainerData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot trainerDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (trainerDoc.exists) {
      return trainerDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchClientRequests() async {
    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('status', isEqualTo: 'pending')
        .get();

    return bookingSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _acceptRequest(
      String requestId, String trainerId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(requestId)
          .update({'trainerId': trainerId, 'status': 'accepted'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Accepted!')),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchTrainerData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final trainerData = snapshot.data!;
            final trainerName = trainerData['name'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Welcome Trainer $trainerName!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Choose Your Client',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchClientRequests(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final clientRequests = snapshot.data!;
                      if (clientRequests.isEmpty) {
                        return const Center(
                          child: Text('No client requests available.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: clientRequests.length,
                        itemBuilder: (context, index) {
                          final request = clientRequests[index];
                          final clientName = request['clientName'] ?? 'No Name';
                          final dateTime =
                              (request['sessionDateTime'] as Timestamp)
                                  .toDate();
                          final formattedDate = DateFormat('dd MMM yyyy (h:mm a)')
                              .format(dateTime);

                          return Card(
                            color: Colors.yellow[700],
                            child: ListTile(
                              title: Text(clientName),
                              subtitle: Text(formattedDate),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  final trainerId =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  _acceptRequest(request['id'], trainerId,
                                      context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('Take'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TrainerSchedule extends StatelessWidget {
  const TrainerSchedule({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchTrainerSchedule() async {
    String trainerId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot scheduleSnapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('trainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: 'accepted')
        .get();

    return scheduleSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchTrainerSchedule(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final schedule = snapshot.data!;
            if (schedule.isEmpty) {
              return const Center(
                child: Text('No scheduled sessions.'),
              );
            }

            return ListView.builder(
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                final session = schedule[index];
                final clientName = session['clientName'] ?? 'No Name';
                final dateTime =
                    (session['sessionDateTime'] as Timestamp).toDate();
                final formattedDate =
                    DateFormat('dd MMM yyyy (h:mm a)').format(dateTime);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(clientName),
                    subtitle: Text(formattedDate),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class TrainerProfile extends StatelessWidget {
  final String trainerName = "angkaramessi";
  final String trainerEmail = "trainer1@gmail.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("images/gr1.jpeg"),
              fit: BoxFit.cover,
            ),
            color: Colors.black.withOpacity(0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Name:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        trainerName,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(color: Colors.grey),
                      const Text(
                        "Email:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        trainerEmail,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LogIn()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
