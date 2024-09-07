import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'createClass.dart';
import 'joinClassroomPage.dart';
import 'signin.dart';  // Import the sign-in page
import 'register.dart'; // Import the register page

class UserClassesPage extends StatefulWidget {
  const UserClassesPage({super.key});

  @override
  _UserClassesPageState createState() => _UserClassesPageState();
}

class _UserClassesPageState extends State<UserClassesPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

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
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Subject: ${classData['subject']}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Class Code: ${classData['classCode']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Created at: ${classData['createdAt'] != null ? (classData['createdAt'] as Timestamp).toDate().toString() : 'N/A'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ],
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
        backgroundColor: Colors.deepPurple,
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
