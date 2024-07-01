// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:myschool/services/FireStore.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final FireStoreService fireStoreService = FireStoreService();
//   final TextEditingController textController = TextEditingController();
//   void openNoteBox({String? docID}) {
//     showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//               content: TextField(controller: textController),
//               actions: [
//                 ElevatedButton(
//                     onPressed: () {
//                       try {
//                         if (docID == null) {
//                           // add a new note
//                           fireStoreService.addNote(textController.text);
//                         } else {
// // update an existing note
//                           fireStoreService.updateNote(
//                               docID, textController.text);
//                         }
//                       } catch (e) {
//                         print(e);
//                       }
//                     },
//                     child: Text('Add'))
//               ],
//             ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Notes')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           fireStoreService.addNote(textController.text);
//           textController.clear();
//           Navigator.pop(context);
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//           stream: fireStoreService.getNotesStream(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               List notesList = snapshot.data!.docs;
//               return ListView.builder(
//                   itemCount: notesList.length,
//                   itemBuilder: (context, index) {
//                     //get the individual doc
//                     DocumentSnapshot document = notesList[index];
//                     String docID = document.id;
//                     // get note from doc
//                     Map<String, dynamic> data =
//                         document.data() as Map<String, dynamic>;
//                     String noteText = data['note'];
//                     return ListTile(
//                         title: Text(noteText),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               onPressed: () {
//                                 openNoteBox(docID: docID);
//                               },
//                               icon: Icon(Icons.settings),
//                             ),
//                             IconButton(
//                               onPressed: () {
//                                 fireStoreService.deleteNote(docID);
//                               },
//                               icon: Icon(Icons.delete),
//                             ),
//                           ],
//                         ));
//                   });
//             } else {
//               return const Text('no available');
//             }
//           }),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myschool/services/FireStore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController textController = TextEditingController();
  void openNoteBox({String? docID, String? previousNote}) {
    textController.text =
        previousNote ?? ''; // Set the previous note's value to the TextField

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (docID == null) {
                        fireStoreService.addNote(textController.text);
                      } else {
                        fireStoreService.updateNote(docID, textController.text);
                      }
                      textController.clear();
                      Navigator.pop(context);
                    },
                    child: Text("Add"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("notes")),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            openNoteBox();
          },
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: fireStoreService.getNotesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
//                   //get the individual doc
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;
//                     // get note from doc
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];
                  return ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              String previousNote =
                                  noteText; // Assuming noteText is the previous note's value

                              openNoteBox(
                                  docID: docID, previousNote: previousNote);
                            },
                            icon: const Icon(Icons.settings),
                          ),
                          IconButton(
                            onPressed: () {
                              fireStoreService.deleteNote(docID);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ));
                },
              );
            } else {
              return Text('done');
            }
          },
        ));
  }
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               onPressed: () {
//                                 openNoteBox(docID: docID);
//                               },
//                               icon: Icon(Icons.settings),
//                             ),
}
