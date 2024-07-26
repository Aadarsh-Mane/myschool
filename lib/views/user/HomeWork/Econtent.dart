import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';

class EcontenScreen extends StatefulWidget {
  final String collectionName;

  const EcontenScreen({super.key, required this.collectionName});
  @override
  _EcontenScreenState createState() => _EcontenScreenState();
}

class _EcontenScreenState extends State<EcontenScreen> {
  // Track the currently selected standard
  String selectedStandard = 'All';

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var cardHeight = screenSize.height * 0.4; // Adjusted height for cards

    return Scaffold(
      backgroundColor:
          Color(0xFFE9E4F0), // Make scaffold background transparent

      body: Container(
        padding: EdgeInsets.only(top: 40, bottom: 20),
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
        child: Column(
          children: [
            // Navigation buttons for standards
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('econtent')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var documents = snapshot.data!.docs;
                  var standards = documents
                      .map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return data['standard'] ?? 'Not Specified';
                      })
                      .toSet()
                      .toList();

                  standards.sort(); // Sort standards alphabetically

                  return Wrap(
                    spacing: 10.0,
                    runSpacing: 5.0,
                    children: [
                      ...standards.map((standard) => ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedStandard = standard;
                              });
                            },
                            child: Text('Standard: $standard'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedStandard == standard
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          )),
                    ],
                  );
                },
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('econtent').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var documents = snapshot.data!.docs;
                var filteredDocs = documents.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var standard = data['standard'] ?? 'Not Specified';
                  return selectedStandard == 'All' ||
                      standard == selectedStandard;
                }).toList();

                return CarouselSlider.builder(
                  options: CarouselOptions(
                    height: cardHeight,
                    enableInfiniteScroll: false,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index, realIdx) {
                    var data =
                        filteredDocs[index].data() as Map<String, dynamic>;

                    var name = data['name'] ?? 'No Name';
                    var description = data['description'] ?? 'No Description';
                    var standard = data['standard'] ?? 'Not Specified';
                    var imageUrls = List<String>.from(data['image_urls'] ?? []);
                    var pdfUrls = List<String>.from(data['pdf_urls'] ?? []);
                    var showReadMore = description.split('\n').length > 3;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          height: cardHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFD3CCE3),
                                Color(0xFFE9E4F0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Text(
                                      'Standard: $standard',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(name),
                                          content: SingleChildScrollView(
                                            child: Text(description),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Close'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailSwiperScreen(
                                          imageUrls: imageUrls,
                                          pdfUrls: pdfUrls,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 100,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        ...imageUrls.map((imageUrl) => Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: 100,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  border: Border.all(
                                                      color: Colors.black54),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            )),
                                        ...pdfUrls.map((pdfUrl) => Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: 100,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  border: Border.all(
                                                      color: Colors.black54),
                                                ),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.picture_as_pdf,
                                                        size: 40,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(height: 4.0),
                                                      Text(
                                                        'PDF',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    String shareText =
                                        "$name - $description...\nDownload our app to see more!";
                                    Share.share(shareText);
                                  },
                                  icon: Icon(Icons.share),
                                  label: Text('Share'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
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
          ],
        ),
      ),
    );
  }
}

class DetailSwiperScreen extends StatelessWidget {
  final List<String> imageUrls;
  final List<String> pdfUrls;

  DetailSwiperScreen({required this.imageUrls, required this.pdfUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: Column(
        children: [
          // Image Carousel
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.6,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                autoPlay: false,
              ),
              items: imageUrls.map((imageUrl) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageZoomScreen(imageUrl: imageUrl),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: 1000.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // PDF Thumbnails
          Expanded(
            child: ListView.builder(
              itemCount: pdfUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PdfViewerScreen(pdfUrl: pdfUrls[index]),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.blueGrey[100],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                        SizedBox(width: 20.0),
                        Expanded(
                          child: Text(
                            'PDF Document ${index + 1}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImageZoomScreen extends StatelessWidget {
  final String imageUrl;
  ImageZoomScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Zoom'),
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;

  PdfViewerScreen({required this.pdfUrl});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool isLoading = true;
  String? localFilePath;
  late PDFViewController pdfController;
  int totalPages = 0;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  Future<void> _downloadAndLoadPdf() async {
    try {
      // Get temporary directory
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/temp.pdf';

      // Download PDF to the local path
      await Dio().download(widget.pdfUrl, path);

      setState(() {
        localFilePath = path;
        isLoading = false;
      });
    } catch (e) {
      print('Error downloading PDF: $e');
      setState(() {
        isLoading = false; // Even if there's an error, stop the loader
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        backgroundColor: Color(0xFF7A9E9F),
      ),
      body: Stack(
        children: [
          if (localFilePath != null)
            PDFView(
              filePath: localFilePath!,
              onViewCreated: (PDFViewController viewController) {
                setState(() {
                  pdfController = viewController;
                });
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  currentPage = page ?? 0; // Handle nullability
                  totalPages = total ?? 0; // Handle nullability
                });
              },
              onPageError: (page, error) {
                print('Error (page: $page): $error');
              },
            ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (!isLoading && localFilePath == null)
            Center(
              child: Text('Failed to load PDF.'),
            ),
        ],
      ),
    );
  }
}
