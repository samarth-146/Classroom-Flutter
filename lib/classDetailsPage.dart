import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassDetailsPage extends StatelessWidget {
  final String classId;
  final DocumentSnapshot classData;

  const ClassDetailsPage({Key? key, required this.classId, required this.classData}) : super(key: key);

  void _deleteClass(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('classes').doc(classId).delete();
      // Navigate back to the class list after deletion
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete class: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classData['className']),
        backgroundColor: Colors.blueGrey[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class Name: ${classData['className']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Subject: ${classData['subject']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Class Code: ${classData['classCode']}',
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Text(
              'Created at: ${(classData['createdAt'] as Timestamp).toDate()}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _deleteClass(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete Class'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
