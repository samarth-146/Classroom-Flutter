import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassInfoPage extends StatefulWidget {
  final DocumentSnapshot infoData;
  final String userId;

  const ClassInfoPage({Key? key, required this.infoData, required this.userId}) : super(key: key);

  @override
  _ClassInfoPageState createState() => _ClassInfoPageState();
}

class _ClassInfoPageState extends State<ClassInfoPage> {
  PlatformFile? _selectedFile;
  String? _currentUserId;
  bool _isCreator = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid;
        _isCreator = widget.userId == _currentUserId; // Check if the current user is the creator
      });
    }
  }

  Future<void> _openPDF(String pdfUrl) async {
    try {
      if (await canLaunch(pdfUrl)) {
        await launch(pdfUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open PDF')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open PDF: $e')),
      );
    }
  }

  Future<void> _submitPdf() async {
    if (_selectedFile == null) return;

    try {
      final file = File(_selectedFile!.path!);
      final storageRef = FirebaseStorage.instance.ref().child('pdfs/${widget.infoData.id}/${_selectedFile!.name}');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final pdfUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.infoData.reference.parent.parent!.id)
          .collection('info')
          .doc(widget.infoData.id)
          .update({'submittedPdf': pdfUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF submitted successfully')),
      );

      Navigator.popUntil(context, ModalRoute.withName('/classDetails'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit PDF: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  DateTime? _parseDueDate(dynamic dueDate) {
    if (dueDate is Timestamp) {
      return dueDate.toDate();
    } else if (dueDate is String) {
      try {
        return DateTime.parse(dueDate);
      } catch (e) {
        print('Failed to parse dueDate string: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final infoData = widget.infoData.data() as Map<String, dynamic>?;

    final dueDate = _parseDueDate(infoData?['dueDate']);
    final isLate = dueDate != null && DateTime.now().isAfter(dueDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Info Details'),
        backgroundColor: Colors.blueGrey[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              infoData?['title'] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 16),
            Text(
              infoData?['description'] ?? 'No Description',
              style: TextStyle(fontSize: 18, color: Colors.blueGrey[600]),
            ),
            const SizedBox(height: 16),
            if (infoData?['pdfUrl'] != null)
              ElevatedButton(
                onPressed: () => _openPDF(infoData!['pdfUrl']),
                child: const Text('Open PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              ),
            if (infoData?['submittedPdf'] != null)
              ElevatedButton(
                onPressed: () => _openPDF(infoData!['submittedPdf']),
                child: const Text('View Submitted PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              ),
            if (dueDate != null) ...[
              const SizedBox(height: 16),
              Text(
                'Due Date: ${DateFormat('yyyy-MM-dd').format(dueDate)}',
                style: TextStyle(fontSize: 16, color: isLate ? Colors.red : Colors.green),
              ),
              Text(
                isLate ? 'Late' : 'On Time',
                style: TextStyle(fontSize: 16, color: isLate ? Colors.red : Colors.green),
              ),
            ],
            if (!_isCreator) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Pick PDF File'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitPdf,
                child: const Text('Submit PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
