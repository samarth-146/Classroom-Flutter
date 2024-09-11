import 'package:flutter/material.dart';
import 'dart:math'; // For random class code generation
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'classPage.dart';

class ClassCreationPage extends StatefulWidget {
  const ClassCreationPage({super.key});

  @override
  _ClassCreationPageState createState() => _ClassCreationPageState();
}

class _ClassCreationPageState extends State<ClassCreationPage> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();


  String _generateClassCode() {
    final random = Random();
    return 'CLASS${random.nextInt(10000).toString().padLeft(4, '0')}'; // Example format: CLASS1234
  }

  void _createClass() async {
    final String className = _classNameController.text.trim();
    final String subject = _subjectController.text.trim();
    final String classCode = _generateClassCode();

    if (className.isEmpty || subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
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
        'joinedUser': [],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class created successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserClassesPage()),
      );
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
        title: const Text('Create Class'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: 'Class Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createClass,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.all(10),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Create Class'),
            ),
          ],
        ),
      ),
    );
  }
}
