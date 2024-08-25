import 'package:flutter/material.dart';
import 'dart:math'; // For random class code generation
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassCreationPage extends StatefulWidget {
  @override
  _ClassCreationPageState createState() => _ClassCreationPageState();
}

class _ClassCreationPageState extends State<ClassCreationPage> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  // Generate a random class code
  String _generateClassCode() {
    final random = Random();
    return 'CLASS${random.nextInt(10000).toString().padLeft(4, '0')}'; // Example format: CLASS1234
  }

  // Create a new class document in Firestore
  void _createClass() async {
    final String className = _classNameController.text.trim();
    final String subject = _subjectController.text.trim();
    final String classCode = _generateClassCode();

    if (className.isEmpty || subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('classes').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'className': className,
        'subject': subject,
        'classCode': classCode,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Class created successfully')),
      );
      // Optionally navigate to another page or clear the form
      Navigator.pop(context); // Go back to the previous page or navigate as needed
    } catch (e) {
      print('Error creating class: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create class: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Class'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(
                labelText: 'Class Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createClass,
              child: Text('Create Class'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.all(10),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
