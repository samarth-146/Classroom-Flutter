import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'pdf_viewer_page.dart';

class ClassInfoPage extends StatefulWidget {
  final DocumentSnapshot infoData;
  final String userId;

  const ClassInfoPage({
    Key? key,
    required this.infoData,
    required this.userId,
  }) : super(key: key);

  @override
  _ClassInfoPageState createState() => _ClassInfoPageState();
}

class _ClassInfoPageState extends State<ClassInfoPage> {
  String? _uploadedPdfUrl;

  @override
  void initState() {
    super.initState();
    _fetchSubmittedPdfUrl();
  }

  Future<void> _fetchSubmittedPdfUrl() async {
    final classId = widget.infoData.reference.parent.parent!.id;
    final infoId = widget.infoData.id;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .collection('info')
        .doc(infoId)
        .get();

    final data = doc.data();
    if (data != null &&
        data.containsKey('submittedBy') &&
        data['submittedBy'] == currentUserId &&
        data.containsKey('submittedPdf')) {
      setState(() {
        _uploadedPdfUrl = data['submittedPdf'];
      });
    }
  }

  Future<void> _uploadPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final storageRef =
          FirebaseStorage.instance.ref().child('submitted_pdfs/$fileName');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      final classId = widget.infoData.reference.parent.parent!.id;
      final infoId = widget.infoData.id;
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('info')
          .doc(infoId)
          .update({
        'submittedPdf': downloadUrl,
        'submittedBy': currentUserId,
      });

      setState(() {
        _uploadedPdfUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF submitted successfully')),
      );
    }
  }

  Future<void> _openPDF(String pdfUrl) async {
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${pdfUrl.split('/').last}');
      await file.writeAsBytes(response.bodyBytes);

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

  @override
  Widget build(BuildContext context) {
    final infoData = widget.infoData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Class Info',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey[600],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              infoData['title'] ?? 'No Title',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              infoData['description'] ?? 'No Description',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueGrey[600],
              ),
            ),
            const SizedBox(height: 16),

            // 🔽 Show creator's attached PDF
            if (infoData.data().toString().contains('pdfUrl') &&
                infoData['pdfUrl'] != null &&
                infoData['pdfUrl'].toString().isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openPDF(infoData['pdfUrl']),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Attached PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),

            const SizedBox(height: 32),
            const Divider(),
            const Text(
              'Upload new PDF:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),

            if (_uploadedPdfUrl != null)
              ElevatedButton.icon(
                onPressed: () => _openPDF(_uploadedPdfUrl!),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Open Your Attachment PDF'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[300]),
              )
            else
              ElevatedButton.icon(
                onPressed: _uploadPdf,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload PDF'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[400]),
              ),
          ],
        ),
      ),
    );
  }
}
