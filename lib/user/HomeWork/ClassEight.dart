import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';

class WorkEight extends StatelessWidget {
  final String collectionName;

  const WorkEight({Key? key, required this.collectionName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy('timestamp', descending: true) // Sort by timestamp
          .snapshots(),
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
            var option = data['option']; // Assuming option is stored as a field
            var dateTime = timestamp.toDate();

            // Customize how you want to display your data here
            return GestureDetector(
              onTap: () {
                // Open a new screen or dialog to display the image with zoom
                if (imageUrl != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ImageZoomScreen(imageUrl: imageUrl)));
                }
              },
              child: Card(
                elevation: 3,
                margin: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    ListTile(
                      title:
                          Text(title != null ? title.toString() : 'No Title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description != null
                              ? description.toString()
                              : 'No Description'),
                          Text(timestamp != null
                              ? 'Date : ${DateFormat('dd-MM-yyyy ').format(dateTime).toString()}'
                              : 'No Timestamp'),
                        ],
                      ),
                      leading: imageUrl != null
                          ? Image.network(
                              imageUrl.toString(),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: Text('No Image'),
                              ),
                            ),
                      // Add more widgets based on your data structure
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          option != null ? option.toString() : '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
        itemCount: 5, // You can adjust the number of shimmer items
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
      ),
      body: imageUrl != null
          ? PhotoViewGallery.builder(
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
            )
          : Center(
              child: Text('No Image'),
            ),
    );
  }
}
