import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For loading spinner

class EcontenScreen extends StatelessWidget {
  final String collectionName;

  const EcontenScreen({Key? key, required this.collectionName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Content - $collectionName'),
        backgroundColor: Color(0xFF7A9E9F), // Custom AppBar color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('data').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ShimmerList(); // Display shimmer while data is loading
          }

          var documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index].data() as Map<String, dynamic>;

              // Extracting fields from data
              var title = data['title'];
              var description = data['description'];
              var timestamp =
                  data['timestamp']; // Assuming timestamp is stored as a field
              var imageUrl =
                  data['image']; // Assuming image URL is stored as a field
              var option =
                  data['option']; // Assuming option is stored as a field

              // Check if timestamp is not null before converting to DateTime
              var dateTime =
                  timestamp != null ? (timestamp as Timestamp).toDate() : null;

              return GestureDetector(
                onTap: () {
                  // Open a new screen or dialog to display the image with zoom
                  if (imageUrl != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageZoomScreen(imageUrl: imageUrl),
                      ),
                    );
                  }
                },
                child: Card(
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFD3CCE3), // Light Purple
                              Color(0xFFE9E4F0), // Light Pink
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title != null ? title.toString() : 'No Title',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              description != null
                                  ? description.toString()
                                  : 'No Description',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              dateTime != null
                                  ? 'Date: ${DateFormat('dd-MM-yyyy').format(dateTime)}'
                                  : 'No Date Available',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            if (imageUrl != null) ...[
                              SizedBox(height: 8.0),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: ClipRect(
                                  child: Image.network(
                                    imageUrl.toString(),
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, progress) {
                                      return progress == null
                                          ? child
                                          : Center(
                                              child: SpinKitCircle(
                                                color: Colors.blue,
                                                size: 50.0,
                                              ),
                                            );
                                    },
                                  ),
                                ),
                              ),
                            ],
                            if (option != null)
                              SizedBox(
                                height: 20,
                              ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  option.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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
            },
          );
        },
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Number of shimmer items
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Container(
                width: double.infinity,
                height: 16.0,
                color: Colors.white,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200.0,
                    height: 12.0,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: 100.0,
                    height: 12.0,
                    color: Colors.white,
                  ),
                ],
              ),
              leading: Container(
                width: 50.0,
                height: 50.0,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageZoomScreen extends StatelessWidget {
  final String? imageUrl;

  const ImageZoomScreen({Key? key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zoomed Image'),
        backgroundColor: Color(0xFF7A9E9F),
      ),
      body: PhotoViewGallery.builder(
        itemCount: 1,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrl!),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(),
      ),
    );
  }
}
