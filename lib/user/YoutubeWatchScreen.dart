import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus package

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
          return _buildMainContent();
        } else {
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
      backgroundColor: Color(0xFFE9E4F0),
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
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      Card(
                        color: Color(0xFFD3CCE3),
                        child: ListTile(
                          onTap: () {
                            _launchURL(videoUrl);
                          },
                          title: Text(
                            videoName,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: videoUrl != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
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
                      // Positioned(
                      //   bottom: 10,
                      //   right: 10,
                      //   child: IconButton(
                      //     onPressed: () {
                      //       _shareVideo(videoName, videoUrl);
                      //     },
                      //     icon: Icon(Icons.share, color: Colors.white),
                      //     color: Colors.transparent,
                      //   ),
                      // )
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: FloatingActionButton(
                          onPressed: () {
                            _shareVideo(videoName, videoUrl);
                          },
                          mini: true,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.share, color: Colors.white),
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

  Widget _buildLazyYoutubePlayer(String? videoUrl) {
    return FutureBuilder(
      future: _initializeYoutubePlayer(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data as Widget;
        } else {
          return CircularProgressIndicator(); // Show a loading indicator
        }
      },
    );
  }

  Future<void> _fetchData() async {
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

  void _shareVideo(String videoName, String? videoUrl) {
    if (videoUrl != null) {
      String shareText =
          "Check out this video: $videoName\n$videoUrl\nShared via our awesome school app!";
      Share.share(shareText);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video URL is invalid!'),
        ),
      );
    }
  }

  _launchURL(String? url) async {
    if (url != null && await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
        ),
      );
    }
  }
}
