import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:classroom/UploadInfoPage.dart'; // Import the UploadInfoPage
import 'package:classroom/ClassInfo.dart'; // Import the ClassInfoPage
import 'pdf_viewer_page.dart'; // Import the PDFViewerPage

class ClassDetailsPage extends StatelessWidget {
  final String classId;
  final DocumentSnapshot classData;

  const ClassDetailsPage({
    Key? key,
    required this.classId,
    required this.classData, required currentUserId,
  }) : super(key: key);

  Future<File> _downloadPDF(String pdfUrl) async {
    final response = await http.get(Uri.parse(pdfUrl));
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${pdfUrl.split('/').last}');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  void _openPDF(BuildContext context, String pdfUrl) async {
    try {
      final file = await _downloadPDF(pdfUrl);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(filePath: file.path),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open PDF: $e')),
      );
    }
  }

  Future<void> _deleteInfo(BuildContext context, String infoId) async {
    final currentUserRole = await _getCurrentUserRole();

    if (currentUserRole == 'admin' || currentUserRole == 'creator') {
      try {
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('info')
            .doc(infoId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Information deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete information: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to delete this information')),
      );
    }
  }

  Future<void> _deleteClass(BuildContext context) async {
    final currentUserRole = await _getCurrentUserRole();

    if (currentUserRole == 'admin' || currentUserRole == 'creator') {
      try {
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .delete();
        Navigator.pop(context); // Navigate back after deleting the class
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete class: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to delete this class')),
      );
    }
  }

  Future<String> _getCurrentUserRole() async {
    // Implement your logic to get the current user's role
    // This is just a placeholder
    return 'creator'; // Replace with actual logic to fetch user role
  }

  void _goToUploadInfoPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadInfoPage(classId: classId)),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Information uploaded successfully')),
      );
    }
  }

  void _goToClassInfoPage(BuildContext context, DocumentSnapshot infoData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClassInfoPage(infoData: infoData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classData['className']),
        backgroundColor: Colors.blueGrey[400],
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () => _goToUploadInfoPage(context),
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () => _deleteClass(context), // Delete class button
          ),
        ],
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
            const SizedBox(height: 16),
            Text(
              'Class Code: ${classData['classCode']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Uploaded Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .doc(classId)
                    .collection('info')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final infoDocs = snapshot.data!.docs;

                  if (infoDocs.isEmpty) {
                    return const Center(child: Text('No information uploaded yet.'));
                  }

                  return ListView.builder(
                    itemCount: infoDocs.length,
                    itemBuilder: (context, index) {
                      final info = infoDocs[index];
                      final Map<String, dynamic>? data = info.data() as Map<String, dynamic>?;
                      final pdfUrl = data != null && data.containsKey('pdfUrl') ? data['pdfUrl'] as String? : null;
                      final infoId = info.id;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        color: Colors.blueGrey[50],
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: InkWell(
                          onTap: () => _goToClassInfoPage(context, info),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  info['title'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  info['description'],
                                  style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
                                ),
                                const SizedBox(height: 8),
                                if (pdfUrl != null && pdfUrl.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () => _openPDF(context, pdfUrl),
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: const Text('Open PDF'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey,
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Uploaded on: ${(info['createdAt'] as Timestamp).toDate()}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteInfo(context, infoId),
                                      ),
                                    ],
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
