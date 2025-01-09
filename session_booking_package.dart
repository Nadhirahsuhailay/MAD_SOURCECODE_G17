import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionBookingPage extends StatefulWidget {
  @override
  _SessionBookingPageState createState() => _SessionBookingPageState();
}

class _SessionBookingPageState extends State<SessionBookingPage> {
  List<Map<String, dynamic>> bookedSessions = [];
  Map<String, dynamic>? pendingSession;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String userId;
  int sessionsRemaining = 0;

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      userId = _auth.currentUser!.uid; // Get logged-in user UID
      _fetchData();
    } else {
      print("Error: No user is currently logged in.");
    }
  }

  Future<void> _fetchData() async {
    await _fetchRemainingSessions();
    await _loadUserSessions();
  }

  Future<void> _fetchRemainingSessions() async {
    try {
      final userDoc = await _firestore.collection('userPackages').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          sessionsRemaining = userDoc.data()?['sessionsRemaining'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching remaining sessions: $e");
    }
  }

  Future<void> _loadUserSessions() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sessions')
          .orderBy('sessionDateTime')
          .get();

      setState(() {
        bookedSessions = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'sessionDateTime': (data['sessionDateTime'] as Timestamp).toDate(),
            'remarks': data['remarks'],
          };
        }).toList();

        _updatePendingSession();
      });
    } catch (error) {
      print("Error loading user sessions: $error");
    }
  }

  void _updatePendingSession() {
    DateTime now = DateTime.now();
    pendingSession = null;

    for (var session in bookedSessions) {
      DateTime sessionDateTime = session['sessionDateTime'];
      if (sessionDateTime.isAfter(now)) {
        if (pendingSession == null || sessionDateTime.isBefore(pendingSession!['sessionDateTime'])) {
          pendingSession = session;
        }
      }
    }

    bookedSessions.sort((a, b) {
      return a['sessionDateTime'].compareTo(b['sessionDateTime']);
    });
  }

 Future<void> _addSession() async {
  if (sessionsRemaining <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("No remaining sessions. Please purchase more."),
      ),
    );
    return;
  }

  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
  );

  if (selectedDate != null) {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final fullDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Add trainerId field
      String trainerId = "YOUR_TRAINER_ID"; // Replace with actual trainer ID logic
      Map<String, dynamic> session = {
        'sessionDateTime': fullDateTime,
        'remarks': '-',
        'createdAt': DateTime.now(),
        'trainerId': trainerId, // Add this
        'status': 'pending', // Add this
      };

      try {
        DocumentReference docRef = await _firestore
            .collection('users')
            .doc(userId)
            .collection('sessions')
            .add(session);

        setState(() {
          bookedSessions.add({
            'id': docRef.id,
            ...session,
          });
          sessionsRemaining -= 1;
          _updatePendingSession();
        });

        await _firestore.collection('userPackages').doc(userId).update({
          'sessionsRemaining': sessionsRemaining,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session booked successfully!")),
        );
      } catch (error) {
        print("Error adding session: $error");
      }
    }
  }
}


  Future<void> _deleteSession(String sessionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sessions')
          .doc(sessionId)
          .delete();

      setState(() {
        bookedSessions.removeWhere((session) => session['id'] == sessionId);
        sessionsRemaining += 1; // Increase remaining sessions
        _updatePendingSession();
      });

      // Update remaining sessions in Firestore
      await _firestore.collection('userPackages').doc(userId).update({
        'sessionsRemaining': sessionsRemaining,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session cancelled successfully.")),
      );
    } catch (error) {
      print("Error deleting session: $error");
    }
  }

  Future<bool> _showCancelConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Session'),
            content: const Text('Are you sure you want to cancel this session?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy, h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "images/gr1.jpeg", // Background image
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.6), // Dark overlay
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Session Booking",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (pendingSession != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date: ${_formatDateTime(pendingSession!['sessionDateTime'])}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text("Remarks: ${pendingSession!['remarks']}"),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              bool confirm = await _showCancelConfirmationDialog();
                              if (confirm) {
                                _deleteSession(pendingSession!['id']);
                              }
                            },
                            child: const Text("Cancel"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: bookedSessions.length,
                      itemBuilder: (context, index) {
                        final session = bookedSessions[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.yellow[700],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date: ${_formatDateTime(session['sessionDateTime'])}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text("Remarks: ${session['remarks']}"),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  bool confirm = await _showCancelConfirmationDialog();
                                  if (confirm) {
                                    _deleteSession(session['id']);
                                  }
                                },
                                child: const Text("Cancel"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSession,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
