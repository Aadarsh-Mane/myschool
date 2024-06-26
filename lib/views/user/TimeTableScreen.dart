import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Add this package for the spinner

class TimeTableScreen extends StatelessWidget {
  final String collectionName;

  const TimeTableScreen({Key? key, required this.collectionName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/logot.png'),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD3CCE3), // Light Purple
            Color(0xFFE9E4F0), // Light Pink
          ],
        ),
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var documents = snapshot.data!.docs;

          // Sort documents based on timestamp
          documents.sort((a, b) {
            Timestamp? timestampA =
                (a.data() as Map<String, dynamic>)['timestamp'];
            Timestamp? timestampB =
                (b.data() as Map<String, dynamic>)['timestamp'];
            DateTime dateTimeA =
                timestampA != null ? timestampA.toDate() : DateTime.now();
            DateTime dateTimeB =
                timestampB != null ? timestampB.toDate() : DateTime.now();
            return dateTimeB.compareTo(dateTimeA);
          });

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var document = documents[index];
              var documentName = document.id; // Retrieve the document name
              var data = document.data() as Map<String, dynamic>;

              // Check if 'url' key is present and non-null
              var url = data['pdf'];
              var urlText = url != null ? url.toString() : '';

              return OpenContainer(
                transitionType: ContainerTransitionType.fade,
                openBuilder: (context, _) => PdfViewerScreen(urlText),
                closedElevation: 0,
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                closedColor: Colors.transparent,
                closedBuilder: (context, openContainer) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD3CCE3), // Light Purple
                          Color(0xFFE9E4F0), // Light Pink
                        ],
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(20),
                      title: Text(
                        'TimeTable: $documentName',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Click to view the timetable',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      trailing:
                          Icon(Icons.picture_as_pdf, color: Colors.black54),
                      onTap: () {
                        if (urlText.isNotEmpty) {
                          openContainer();
                        }
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
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
  Future<String>? localFilePathFuture;

  @override
  void initState() {
    super.initState();
    localFilePathFuture = _downloadFile(widget.pdfUrl);
  }

  Future<String> _downloadFile(String url) async {
    Dio dio = Dio();
    var tempDir = await getTemporaryDirectory();
    String localFilePath = '${tempDir.path}/temp.pdf';
    try {
      await dio.download(url, localFilePath);
      return localFilePath;
    } catch (e) {
      print('Error downloading file: $e');
      throw e; // rethrow the exception to handle it in the FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        backgroundColor: Color(0xFF7A9E9F),
      ),
      body: FutureBuilder<String>(
        future: localFilePathFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFadingCircle(
                color: Colors.black54,
                size: 50.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading PDF'),
            );
          } else if (snapshot.hasData) {
            return PDFView(
              filePath: snapshot.data!,
            );
          } else {
            return Center(
              child: Text('No PDF available'),
            );
          }
        },
      ),
    );
  }
}
