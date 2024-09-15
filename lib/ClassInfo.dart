import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassInfoPage extends StatelessWidget {
  final DocumentSnapshot infoData;

  const ClassInfoPage({Key? key, required this.infoData}) : super(key: key);

  Future<void> _openPDF(String pdfUrl) async {
    if (await canLaunch(pdfUrl)) {
      await launch(pdfUrl);
    } else {
      throw 'Could not launch $pdfUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfUrl = infoData['pdfUrl'];

    return Scaffold(
      appBar: AppBar(
        title: Text(infoData['title']),
        backgroundColor: Colors.blueGrey[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${infoData['title']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Description: ${infoData['description']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (pdfUrl != null)
              ElevatedButton.icon(
                onPressed: () {
                  _openPDF(pdfUrl);
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Open PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
