import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class UploadInfoPage extends StatefulWidget {
  final String classId;

  const UploadInfoPage({Key? key, required this.classId}) : super(key: key);

  @override
  _UploadInfoPageState createState() => _UploadInfoPageState();
}

class _UploadInfoPageState extends State<UploadInfoPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  Future<void> _uploadInfo() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final dueDate = dueDateController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description cannot be empty.')),
      );
      return;
    }

    try {
      String? pdfUrl;

      if (_selectedFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('class_pdfs/${_selectedFile!.name}');

        // Upload the file
        if (_selectedFile!.bytes != null) {
          await storageRef.putData(_selectedFile!.bytes!);
        } else if (_selectedFile!.path != null) {
          final file = File(_selectedFile!.path!);
          await storageRef.putFile(file);
        }

        pdfUrl = await storageRef.getDownloadURL();
      }

      // Prepare data to store in Firestore
      Map<String, dynamic> data = {
        'title': title,
        'description': description,
        'createdAt': Timestamp.now(),
        'pdfUrl': pdfUrl, // Save the URL of the uploaded PDF if available
      };

      // Store the info in Firestore
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('info')
          .add(data);

      // Pop the page and pass a success flag back
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload info: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text('Upload Information',
              style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        backgroundColor: Colors.blueGrey[400],
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the back button color to white
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Class Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(
                      Icons.attach_file,
                      color: Colors.white,
                    ),
                    label: const Text('Attach PDF (optional)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadInfo,
                    child: const Text('Upload Info'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
