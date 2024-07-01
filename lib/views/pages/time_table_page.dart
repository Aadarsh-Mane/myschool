import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class TimetablePage extends StatelessWidget {
  const TimetablePage({Key? key}) : super(key: key);

  Future<void> uploadFile(BuildContext context) async {
    TextEditingController classNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Upload Timetable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: classNameController,
              decoration: InputDecoration(labelText: 'Class Name'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                String className = classNameController.text.trim();
                if (className.isNotEmpty) {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (result != null) {
                    File file = File(result.files.single.path!);
                    String fileName =
                        '${DateTime.now().millisecondsSinceEpoch}_$className.pdf';
                    Reference ref = FirebaseStorage.instance
                        .ref()
                        .child('timetable/$fileName');
                    UploadTask uploadTask = ref.putFile(file);

                    await uploadTask.whenComplete(() async {
                      String downloadUrl = await ref.getDownloadURL();
                      await FirebaseFirestore.instance
                          .collection('timetable')
                          .doc(className)
                          .set({'pdf': downloadUrl});
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a class name')),
                  );
                }
              },
              child: Text('Upload PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteDocument(String className, String documentId) async {
    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('timetable').doc(className);
      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        String? downloadUrl = snapshot.get('pdf');
        await docRef.delete();

        if (downloadUrl != null) {
          Reference ref = FirebaseStorage.instance.refFromURL(downloadUrl);
          await ref.delete();
        }
      }
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                uploadFile(context);
              },
              child: const Text('Upload Timetable PDF'),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('timetable')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                List<QueryDocumentSnapshot> data = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Class Name')),
                      DataColumn(label: Text('Timetable PDF')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: data
                        .map(
                          (QueryDocumentSnapshot document) => DataRow(
                            cells: [
                              DataCell(Text(document.id)),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () async {
                                    String? pdfUrl = document['pdf'] as String?;
                                    if (pdfUrl != null) {
                                      if (await canLaunch(pdfUrl)) {
                                        await launch(pdfUrl);
                                      } else {
                                        throw 'Could not launch $pdfUrl';
                                      }
                                    }
                                  },
                                  child: Text('Open Timetable'),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    deleteDocument(document.id, document.id);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
