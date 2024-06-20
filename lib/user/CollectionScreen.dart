import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:myschool/pages/HomeWork.dart';
import 'package:myschool/user/HomeWork/ClassEight.dart';
import 'package:myschool/user/HomeWork/HomeWorkSpecific.dart';
import 'package:myschool/user/TimeTableScreen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

// class CollectionDataScreen extends StatelessWidget {
//   final String collectionName;

//   const CollectionDataScreen({Key? key, required this.collectionName})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Collection Data - $collectionName'),
//       ),
//       body: Collection1DataList(collectionName: collectionName),
//     );
//   }
// }

class CollectionDataScreen extends StatelessWidget {
  final String collectionName;

  const CollectionDataScreen({Key? key, required this.collectionName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Collection Data - $collectionName'),
      // ),
      body: getCollectionDataWidget(collectionName),
    );
  }

  Widget getCollectionDataWidget(String collectionName) {
    switch (collectionName) {
      case 'notes':
        return Collection1DataList(
          collectionName: 'notes',
        );
      case 'timetable':
        return TimeTableScreen(
          collectionName: 'timetable',
        );
      case 'data':
        return Collection2DataList(
          collectionName: 'timetable',
        );
      case 'nineth':
        return HomeWorkSpecific(
          collectionName: 'nineth',
        );
      case 'Eight':
        return WorkEight(
          collectionName: 'Eight',
        );

      // Add more cases for each collection
      default:
        return Text('Unknown Collection');
    }
  }
}

class FadeInText extends StatefulWidget {
  final String text;

  const FadeInText(this.text, {required TextStyle style});

  @override
  _FadeInTextState createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Set up animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Set up animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start the animation
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Text(widget.text),
    );
  }

  @override
  void dispose() {
    // Dispose of the animation controller
    _controller.dispose();
    super.dispose();
  }
}

// class Collection1DataList extends StatelessWidget {
//   final String collectionName;

//   const Collection1DataList({Key? key, required this.collectionName})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: double.infinity, // Make the container fill the entire height
//       color: Color(0xFFF5EEE6),
//       child: Column(
//         children: [
//           // Widget above the cards (Add something beautiful here)
//           // Container(
//           //   height: 100,
//           //   decoration: BoxDecoration(
//           //     // color: Color(0xFFFFF8E3),
//           //     color: Color(0xFFF5EEE6), // Set the background color here

//           //     borderRadius: BorderRadius.only(
//           //       bottomRight: Radius.circular(100.0),
//           //       bottomLeft: Radius.circular(100.0),
//           //     ),
//           //     boxShadow: [
//           //       BoxShadow(
//           //         color: Colors.grey.withOpacity(0.5),
//           //         spreadRadius: 5,
//           //         blurRadius: 10,
//           //         offset: Offset(0, 3),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           // SizedBox(
//           //   height: 200,
//           // ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(
//                   top: 20.0), // Add padding to move cards down
//               child: Container(
//                 decoration: BoxDecoration(
//                   // color: Color(0xFFFFF8E3),
//                   color: Color(0xFFF5EEE6), // Set the background color here

//                   borderRadius: BorderRadius.only(
//                     bottomRight: Radius.circular(100.0),
//                   ),
//                 ),
//                 // color: Color(0xFFF5EEE6), // Set the background color here
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection(collectionName)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     }

//                     var documents = snapshot.data!.docs;
//                     // Sort documents by timestamp in descending order
//                     documents.sort((a, b) {
//                       Timestamp timestampA =
//                           (a.data() as Map<String, dynamic>)['timestamp'];
//                       Timestamp timestampB =
//                           (b.data() as Map<String, dynamic>)['timestamp'];
//                       return timestampB.compareTo(timestampA);
//                     });

//                     return Container(
//                       // height: 200,
//                       // margin: EdgeInsets.only(right: 100),
//                       child: ListView.builder(
//                         itemCount: documents.length,
//                         itemBuilder: (context, index) {
//                           var data =
//                               documents[index].data() as Map<String, dynamic>;

//                           var notes = data['note'];
//                           var timestamp =
//                               (data['timestamp'] as Timestamp).toDate();

//                           return Hero(
//                             tag: 'card$index', // Unique tag for each card
//                             child: Card(
//                               elevation: 5,
//                               margin: EdgeInsets.fromLTRB(10, 5, 10, 15),
//                               // shape: RoundedRectangleBorder(
//                               //     borderRadius: BorderRadius.circular(
//                               //         15.0)), // Adjust the margins
//                               child: InkWell(
//                                 onTap: () {
//                                   // Add navigation or additional functionality here
//                                 },
//                                 child: Container(
//                                   // decoration: BoxDecoration(
//                                   //   boxShadow: [
//                                   //     BoxShadow(
//                                   //       color: Color(0xFFFFFFE5E5),
//                                   //       spreadRadius: 5,
//                                   //       blurRadius: 10,
//                                   //       offset: Offset(0, 3),
//                                   //     ),
//                                   // ],
//                                   // ),
//                                   margin: EdgeInsets.all(10.0),
//                                   child: ListTile(
//                                     title: FadeInText(
//                                       notes != null
//                                           ? notes.toString()
//                                           : 'No Notes Available',
//                                     ),
//                                     subtitle: FadeInText(
//                                       'Date Created: ${DateFormat('dd-MM-yyyy ').format(timestamp)}',
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class Collection1DataList extends StatelessWidget {
  final String collectionName;

  const Collection1DataList({Key? key, required this.collectionName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: Color(0xFFF5EEE6),
      child: Column(
        children: [
          // Widget above the cards (Add something beautiful here)
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Color(0xFFF5EEE6),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(100.0),
              ),
            ),
            // Add other widgets or content here
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5EEE6),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(100.0),
                  ),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(collectionName)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Shimmer.fromColors(
                        period:
                            Duration(seconds: 5), // Set the shimmer duration

                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: ListView.builder(
                          itemCount: 5, // Number of shimmer items
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
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
                              ),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 20.0,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      height: 20.0,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    var documents = snapshot.data!.docs;
                    documents.sort((a, b) {
                      Timestamp timestampA =
                          (a.data() as Map<String, dynamic>)['timestamp'];
                      Timestamp timestampB =
                          (b.data() as Map<String, dynamic>)['timestamp'];
                      return timestampB.compareTo(timestampA);
                    });

                    return Container(
                      child: ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          var data =
                              documents[index].data() as Map<String, dynamic>;

                          var notes = data['note'];
                          var timestamp =
                              (data['timestamp'] as Timestamp).toDate();

                          return Hero(
                            tag: 'card$index',
                            child: Card(
                              // color: Colors.red,
                              elevation: 8,
                              margin: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Add navigation or additional functionality here
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color.fromARGB(
                                            255, 234, 195, 234), // Start color
                                        Color(
                                            0xFF97D9E1), // End color, // End color
                                      ], // Example gradient colors
                                    ),
                                  ),
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FadeInText(
                                        notes != null
                                            ? notes.toString()
                                            : 'No Notes Available',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Date Created: ${DateFormat('dd-MM-yyyy ').format(timestamp)}',
                                        style: TextStyle(
                                          color:
                                              Colors.red, // Change color here
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Collection2DataList extends StatelessWidget {
  final String collectionName;

  const Collection2DataList({Key? key, required this.collectionName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
            var option = data['option']; // Assuming option is stored as a field
            var dateTime = timestamp.toDate();

            // Customize how you want to display your data here
            return GestureDetector(
              onTap: () {
                // Open a new screen or dialog to display the image with zoom
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ImageZoomScreen(imageUrl: imageUrl),
                  ),
                );
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
                          : Container(),
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
