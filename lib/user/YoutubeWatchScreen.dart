import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubeListPage extends StatefulWidget {
  @override
  _YoutubeListPageState createState() => _YoutubeListPageState();
}

class _YoutubeListPageState extends State<YoutubeListPage> {
  final linkRef = FirebaseFirestore.instance.collection('links');
  late List<DocumentSnapshot> documents;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Data has been loaded, show the main content
          return _buildMainContent();
        } else {
          // Data is still loading, show a splash screen
          return _buildSplashScreen();
        }
      },
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      // backgroundColor: Colors.black,
      backgroundColor: Color(0xFFF5EEE6),

      // appBar: AppBar(
      //   title: Text('YouTube Video List'),
      //   backgroundColor: Colors.blueAccent,
      // ),
      body: StreamBuilder(
        stream: linkRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              String videoName = documents[index]['videoName'];
              String? videoUrl = documents[index]['url'];

              return Container(
                decoration: BoxDecoration(
                  // color: Color(0xFFFFF8E3),    color: Color(0xFFF5EEE6), // Set the background color here

                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 20.0),
                  child: Card(
                    elevation:
                        0, // Remove elevation from Card since it's now handled by BoxDecoration

                    // color: Colors.grey[900],
                    color: Color(0xFFF5EEE6),

                    child: InkWell(
                      onTap: () {
                        _launchURL(videoUrl);
                      },
                      child: ListTile(
                        title: Text(
                          videoName,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: videoUrl != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Lazy load YoutubePlayer
                                  _buildLazyYoutubePlayer(videoUrl),
                                  SizedBox(height: 10),
                                  Text(
                                    videoUrl,
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Lazy load YoutubePlayer
  Widget _buildLazyYoutubePlayer(String? videoUrl) {
    return FutureBuilder(
      future: _initializeYoutubePlayer(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data as Widget;
        } else {
          return Container(); // You can use a loading indicator here
        }
      },
    );
  }

  Future<void> _fetchData() async {
    // Simulate a delay (replace this with your actual data fetching logic)
    await Future.delayed(Duration(seconds: 2));
  }

  Future<Widget> _initializeYoutubePlayer(String? videoUrl) async {
    if (videoUrl != null) {
      String videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? '';

      YoutubePlayerController _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          controlsVisibleAtStart: true,
          enableCaption: true,
          isLive: false,
        ),
      );

      return YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        progressColors: ProgressBarColors(
          playedColor: Colors.blueAccent,
          handleColor: Colors.blueAccent,
        ),
      );
    } else {
      return Container();
    }
  }

  _launchURL(String? url) async {
    if (url != null && await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error, e.g., show an error dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
        ),
      );
    }
  }
}
