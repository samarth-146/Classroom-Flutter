import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinClassroomPage extends StatefulWidget {
  const JoinClassroomPage({super.key});

  @override
  _JoinClassroomPageState createState() => _JoinClassroomPageState();
}

class _JoinClassroomPageState extends State<JoinClassroomPage> {
  final TextEditingController _classCodeController = TextEditingController();

  void _joinClass() async {
    final String classCode = _classCodeController.text.trim();
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    if (classCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a class code')),
      );
      return;
    }

    try {
      // Find the class by class code
      final classQuery = await FirebaseFirestore.instance
          .collection('classes')
          .where('classCode', isEqualTo: classCode)
          .limit(1)
          .get();

      if (classQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class not found')),
        );
        return;
      }

      final classDoc = classQuery.docs.first;
      final classRef = classDoc.reference;

      // Add userId to the joinedUser field
      await classRef.update({
        'joinedUser': FieldValue.arrayUnion([userId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Joined the class successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error joining class: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join class: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Classroom'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _classCodeController,
              decoration: const InputDecoration(
                labelText: 'Class Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinClass,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.all(10),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Join Class'),
            ),
          ],
        ),
      ),
    );
  }
}
