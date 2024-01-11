import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class TimetablePage extends StatelessWidget {
  const TimetablePage({Key? key}) : super(key: key);

  Future<void> uploadFile(String column) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_$column.pdf';
      Reference ref =
          FirebaseStorage.instance.ref().child('timetable/$fileName');
      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() async {
        String downloadUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('timetable')
            .doc(column)
            .set({'url': downloadUrl});
      });
    }
  }

  Future<void> deleteDocument(String column, String documentId) async {
    // Get reference to the document
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('timetable').doc(column);

    // Fetch the document snapshot
    DocumentSnapshot snapshot = await docRef.get();

    // Check if the document exists
    if (snapshot.exists) {
      // Get the URL from the document data
      String? downloadUrl = snapshot.get('url');

      // Delete the document from Firestore
      await docRef.delete();

      // Delete the corresponding file from Firebase Storage
      if (downloadUrl != null) {
        Reference ref = FirebaseStorage.instance.refFromURL(downloadUrl);
        await ref.delete();
      }
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
          children: [
            ElevatedButton(
              onPressed: () {
                uploadFile('column1');
              },
              child: const Text('Upload PDF 1'),
            ),
            ElevatedButton(
              onPressed: () {
                uploadFile('column2');
              },
              child: const Text('Upload PDF 2'),
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

                // Print out document information for debugging
                data.forEach((doc) {
                  print('Document ID: ${doc.id}, URL: ${doc['url']}');
                });

                print('Number of documents: ${data.length}');

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Column')),
                      DataColumn(label: Text('PDF URL')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: data
                        .map(
                          (QueryDocumentSnapshot document) => DataRow(
                            cells: [
                              DataCell(Text(document.id)),
                              DataCell(
                                InkWell(child: Text(document['url'] ?? '')),
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
