import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myschool/user/TimeTableScreen.dart';

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
      // Add more cases for each collection
      default:
        return Text('Unknown Collection');
    }
  }
}

class Collection1DataList extends StatelessWidget {
  final String collectionName;

  const Collection1DataList({Key? key, required this.collectionName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('notes').snapshots(),
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
            var data = documents[index].data() as Map<String, dynamic>;

            // Check if 'notes' key is present and non-null
            var notes = data['note'];
            var notesText =
                notes != null ? notes.toString() : 'No Notes Available';

            // Customize how you want to display your data here
            return ListTile(
              title: Text(notesText),
              // Add more widgets based on your data structure
            );
          },
        );
      },
    );
  }
}
