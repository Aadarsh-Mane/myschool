import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TimeTableScreen extends StatelessWidget {
  final String collectionName;

  const TimeTableScreen({Key? key, required this.collectionName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collection Data - $collectionName'),
      ),
      body: CollectionDataList(collectionName: collectionName),
    );
  }
}

class CollectionDataList extends StatelessWidget {
  final String collectionName;

  const CollectionDataList({Key? key, required this.collectionName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var document = documents[index];
            var documentName = document.id; // Retrieve the document name

            var data = document.data() as Map<String, dynamic>;

            // Check if 'url' key is present and non-null
            var url = data['url'];
            var urlText = url != null ? url.toString() : '';

            // Display PDF link as a button
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TimeTable: $documentName'),
                  ElevatedButton(
                    onPressed: () {
                      if (urlText.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreen(urlText),
                          ),
                        );
                      }
                    },
                    child: Text('Open PDF'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;

  PdfViewerScreen(this.pdfUrl);

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    Dio dio = Dio();
    var tempDir = await getTemporaryDirectory();
    localFilePath = '${tempDir.path}/temp.pdf';
    try {
      await dio.download(widget.pdfUrl, localFilePath);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('error in $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: localFilePath != null
          ? PDFView(
              filePath: localFilePath,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
