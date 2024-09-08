import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'createClass.dart';
import 'joinClassroomPage.dart';
import 'signin.dart';
import 'register.dart';
import 'classDetailsPage.dart'; // Import the new class details page

class UserClassesPage extends StatefulWidget {
  const UserClassesPage({super.key});

  @override
  _UserClassesPageState createState() => _UserClassesPageState();
}

class _UserClassesPageState extends State<UserClassesPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  // Define an array of distinct colors
  final List<Color> cardColors = [
    Colors.purple.shade100,
    Colors.lime.shade200,
    Colors.blueGrey.shade300,
    Colors.cyan.shade100,
    Colors.yellow.shade200,
    Colors.lightGreen.shade300,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _navigateToCreateClassPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClassCreationPage()),
    );
  }

  void _navigateToJoinClassPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinClassroomPage()),
    );
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
          (route) => false,
    );
  }

  void _navigateToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Widget _buildClassList(Stream<QuerySnapshot> classStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: classStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No classes found.'));
        }

        final classes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final classData = classes[index];

            // Assign a color based on the index by cycling through cardColors
            final assignedColor = cardColors[index % cardColors.length];

            return GestureDetector(
              onTap: () {
                // Navigate to the ClassDetailsPage when the card is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassDetailsPage(
                      classId: classData.id, // Pass the class ID
                      classData: classData,  // Pass the class data
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: assignedColor, // Use the assigned color for the card
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classData['className'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Subject: ${classData['subject']}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Class Code: ${classData['classCode']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Created at: ${classData['createdAt'] != null ? (classData['createdAt'] as Timestamp).toDate().toString() : 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        backgroundColor: Colors.blueGrey[400],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: _navigateToJoinClassPage,
            tooltip: 'Join Classroom',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'register') {
                _navigateToRegisterPage();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
              const PopupMenuItem(
                value: 'register',
                child: Text('Register'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Created Classes"),
            Tab(text: "Joined Classes"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Created Classes Tab
          _buildClassList(
            _firestore
                .collection('classes')
                .where('userId', isEqualTo: _auth.currentUser!.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
          ),
          // Joined Classes Tab
          _buildClassList(
            _firestore
                .collection('classes')
                .where('joinedUser', arrayContains: _auth.currentUser!.uid) // Using 'joinedUser' field
                .orderBy('createdAt', descending: true)
                .snapshots(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateClassPage,
        backgroundColor: Colors.green.shade400,
        child: const Icon(Icons.add),
      ),
    );
  }
}
