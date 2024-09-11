import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassDetailsPage extends StatelessWidget {
  final String classId;
  final DocumentSnapshot classData;

  const ClassDetailsPage({Key? key, required this.classId, required this.classData}) : super(key: key);

  void _deleteClass(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('classes').doc(classId).delete();
      Navigator.pop(context); // Navigate back after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete class: $e')),
      );
    }
  }

  void _leaveClass(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final currentUserId = auth.currentUser?.uid;

    try {
      // Remove userId from the joinedUser array
      await FirebaseFirestore.instance.collection('classes').doc(classId).update({
        'joinedUser': FieldValue.arrayRemove([currentUserId]),
      });
      Navigator.pop(context); // Navigate back after leaving the class
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave class: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final currentUserId = auth.currentUser?.uid;

    // Check if the current user is the creator of the class
    final isCreator = classData['userId'] == currentUserId;
    // Check if the current user has joined the class
    final hasJoined = (classData['joinedUser'] as List<dynamic>).contains(currentUserId);

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
            if (isCreator) // Show delete button only if the current user is the creator
              Center(
                child: ElevatedButton(
                  onPressed: () => _deleteClass(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Delete Class'),
                ),
              ),
            if (!isCreator && hasJoined) // Show leave button only if the user has joined the class
              Center(
                child: ElevatedButton(
                  onPressed: () => _leaveClass(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white
                  ),
                  child: const Text('Leave Class'),
                ),
              ),
            if (!isCreator && !hasJoined) // Show message for users who haven't joined the class
              Center(
                child: const Text(
                  'You are not a participant of this class.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            // if (!isCreator) // Show message for non-creators that they cannot delete the class
            //   Center(
            //     child: const Text(
            //       'Only the class creator can delete this class.',
            //       style: TextStyle(fontSize: 16, color: Colors.red),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
