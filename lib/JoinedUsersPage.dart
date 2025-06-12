// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JoinedUsersPage extends StatelessWidget {
  final String classId;

  const JoinedUsersPage(this.classId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: const Text('Joined Users',
                style: const TextStyle(fontSize: 24, color: Colors.white))),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey[600],
        // actions: [
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('classes').doc(classId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final joinedUserIds = data?['joinedUser'] as List<dynamic>? ?? [];

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: Future.wait(joinedUserIds.map((userId) async {
              final userSnap = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get();
              final userData = userSnap.data() ?? {};
              return {
                'username': userData['username'] ?? 'No Name',
                'email': userData['email'] ?? 'No Email',
              };
            })),
            builder: (context, usersSnapshot) {
              if (usersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = usersSnapshot.data ?? [];

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Email')),
                  ],
                  rows: users.map((user) {
                    return DataRow(cells: [
                      DataCell(Text(user['username'])),
                      DataCell(Text(user['email'])),
                    ]);
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
