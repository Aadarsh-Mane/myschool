import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YoutubePage extends StatefulWidget {
  @override
  _YoutubePageState createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _videoNameController = TextEditingController();
  final linkRef = FirebaseFirestore.instance.collection('links');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Storage App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _linkController,
              decoration: InputDecoration(labelText: 'Enter YouTube Link'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _videoNameController,
              decoration: InputDecoration(labelText: 'Enter Video Name'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                saveLink();
              },
              child: Text('Save Link'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                retrieveLinks();
              },
              child: Text('Retrieve Links'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder(
                stream: linkRef.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      String link = documents[index]['url'];
                      String videoName = documents[index]['videoName'];

                      return ListTile(
                        title: Text(videoName),
                        subtitle: Text(link),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                updateLink(
                                  documents[index].id,
                                  link: link,
                                  videoName: videoName,
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                deleteLink(documents[index].id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveLink() {
    String link = _linkController.text.trim();
    String videoName = _videoNameController.text.trim();

    // Validate the link using the provided regular expression
    RegExp regex =
        RegExp(r"^(https?\:\/\/)?((www\.)?youtube\.com|youtu\.?be)\/.+$");

    if (regex.hasMatch(link) && videoName.isNotEmpty) {
      linkRef.add({'url': link, 'videoName': videoName}).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link saved successfully!'),
          ),
        );

        // Clear the TextFields after saving the link
        _linkController.clear();
        _videoNameController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving link. Please try again.'),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid YouTube link and video name.'),
        ),
      );
    }
  }

  void retrieveLinks() {
    linkRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc.data());
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error retrieving links. Please try again.'),
        ),
      );
    });
  }

  void updateLink(String documentId,
      {required String link, required String videoName}) {
    // Implement the update operation here
    // You can open a dialog or navigate to another screen for updating the link
  }

  void deleteLink(String documentId) {
    linkRef.doc(documentId).delete().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link deleted successfully!'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting link. Please try again.'),
        ),
      );
    });
  }
}
