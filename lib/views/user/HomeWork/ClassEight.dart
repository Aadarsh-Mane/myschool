import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Main Collection Screen that can be reused for different classes
class ClassOne extends StatelessWidget {
  final String collectionName;

  const ClassOne({Key? key, required this.collectionName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CollectionDataWidget(collectionName: collectionName),
    );
  }
}

// Widget to fetch and display collection data
class CollectionDataWidget extends StatelessWidget {
  final String collectionName;

  const CollectionDataWidget({Key? key, required this.collectionName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/logot.png'),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD3CCE3), Color(0xFFE9E4F0)],
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collectionName)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index].data() as Map<String, dynamic>;

              return DocumentCard(data: data, screenSize: screenSize);
            },
          );
        },
      ),
    );
  }
}

// Reusable widget to display a document in a card
class DocumentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Size screenSize;

  const DocumentCard({Key? key, required this.data, required this.screenSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var title = data['title'] ?? 'No Title';
    var description = data['description'] ?? 'No Description';
    var timestamp = (data['timestamp'] as Timestamp).toDate();
    var imageUrls = List<String>.from(data['images'] ?? []);
    var division = data['division'] ?? 'No Division';

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Card(
        elevation: 10,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        color: Colors.black,
        shadowColor: Colors.black,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD3CCE3), Color(0xFFE9E4F0)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Division
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: screenSize.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DivisionBadge(division: division, screenSize: screenSize),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.01),
                // Description with Read More functionality
                ExpandableText(
                  text: description,
                  maxLines: 3,
                  fontSize: screenSize.width * 0.04,
                ),
                SizedBox(height: screenSize.height * 0.01),
                // Timestamp
                Text(
                  'Date created: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp)}',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.035,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                // Images
                ImageViewer(imageUrls: imageUrls, screenSize: screenSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget for the division badge
class DivisionBadge extends StatelessWidget {
  final String division;
  final Size screenSize;

  const DivisionBadge(
      {Key? key, required this.division, required this.screenSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.02,
        vertical: screenSize.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: Text(
        'Division $division',
        style: TextStyle(
          fontSize: screenSize.width * 0.035,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

// Expandable Text Widget
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final double fontSize;

  const ExpandableText({
    Key? key,
    required this.text,
    this.maxLines = 3,
    required this.fontSize,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(fontSize: widget.fontSize),
        ),
        GestureDetector(
          onTap: _toggleExpanded,
          child: Text(
            _isExpanded ? 'Read Less' : 'Read More',
            style: TextStyle(
              color: Colors.blue,
              fontSize: widget.fontSize * 0.85,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Image Viewer Widget
class ImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final Size screenSize;

  const ImageViewer(
      {Key? key, required this.imageUrls, required this.screenSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.height * 0.25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          var imageUrl = imageUrls[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageZoomScreen(imageUrl: imageUrl),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(screenSize.width * 0.02),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  imageUrl,
                  width: screenSize.width * 0.35,
                  height: screenSize.height * 0.25,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Image Zoom Screen
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
