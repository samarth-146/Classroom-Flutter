import 'package:classroom/createClass.dart';
import 'package:classroom/joinClassroomPage.dart';
import 'package:classroom/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class bottomNavigation extends StatefulWidget {
  const bottomNavigation({super.key});

  @override
  State<bottomNavigation> createState() => _bottomNavigationState();
}

class _bottomNavigationState extends State<bottomNavigation> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
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

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle actions for each item
    if (index == 0) {
      // Add Class logic
      _navigateToJoinClassPage();
      print("Add Class tapped");
    } else if (index == 1) {
      _navigateToCreateClassPage();
    } else if (index == 2) {
      // Logout logic
      _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blueGrey, // color for selected item
      unselectedItemColor: Colors.blueGrey,
       // color for unselected items (same)
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Join class',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.create),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }
}
