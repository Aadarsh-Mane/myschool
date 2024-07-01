import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

// class AdminScreen extends StatefulWidget {
//   @override
//   _AdminScreenState createState() => _AdminScreenState();
// }

// class _AdminScreenState extends State<AdminScreen> {
//   // Reference to the Firestore collection
//   final CollectionReference buyersCollection =
//       FirebaseFirestore.instance.collection('buyers');

//   // Controllers for the text fields
//   final TextEditingController fullNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();

//   // Method to add a buyer
//   Future<void> addBuyer(String fullName, String email) {
//     return buyersCollection.add({
//       'fullName': fullName,
//       'email': email,
//     });
//   }

//   // Method to delete a buyer
//   Future<void> deleteBuyer(String id) {
//     return buyersCollection.doc(id).delete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Admin Dashboard'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             // StreamBuilder to fetch real-time updates from Firestore
//             child: StreamBuilder(
//               stream: buyersCollection.snapshots(),
//               builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 final buyers = snapshot.data!.docs;

//                 // ListView to display all buyers
//                 return ListView.builder(
//                   itemCount: buyers.length,
//                   itemBuilder: (context, index) {
//                     final buyer = buyers[index];

//                     return ListTile(
//                       title: Text(buyer['fullName']),
//                       subtitle: Text(buyer['email']),
//                       trailing: IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () => deleteBuyer(buyer.id),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           // Padding for input fields and button
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: fullNameController,
//                   decoration: InputDecoration(labelText: 'fullName'),
//                 ),
//                 TextField(
//                   controller: emailController,
//                   decoration: InputDecoration(labelText: 'Email'),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     final fullName = fullNameController.text;
//                     final email = emailController.text;

//                     if (fullName.isNotEmpty && email.isNotEmpty) {
//                       addBuyer(fullName, email);
//                       fullNameController.clear();
//                       emailController.clear();
//                     }
//                   },
//                   child: Text('Add Buyer'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AdminRespect extends StatefulWidget {
//   @override
//   _AdminRespectState createState() => _AdminRespectState();
// }

// class _AdminRespectState extends State<AdminRespect> {
//   // Fetch all collections from Firestore
//   Future<List<String>> _getCollections() async {
//     List<String> collections = [];
//     var firestore = FirebaseFirestore.instance;

//     // Get all collection references
//     var collectionsRefs = await firestore.listCollections();
//     for (var collection in collectionsRefs) {
//       collections.add(collection.id);
//     }

//     return collections;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Firestore Collections'),
//       ),
//       body: FutureBuilder<List<String>>(
//         future: _getCollections(),
//         builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No collections found.'));
//           } else {
//             // Display the list of collections
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(snapshot.data![index]),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

class AdminRespect extends StatefulWidget {
  @override
  _AdminRespectState createState() => _AdminRespectState();
}

class _AdminRespectState extends State<AdminRespect> {
  Future<List<Map<String, dynamic>>> _getCollections() async {
    final response = await http
        .get(Uri.parse('https://pushnotify-2w2v.onrender.com/collections'));

    if (response.statusCode == 200) {
      List<dynamic> collections = jsonDecode(response.body)['collections'];
      return collections
          .map((collection) =>
              {'id': collection['id'], 'length': collection['length']})
          .toList();
    } else {
      throw Exception('Failed to load collections');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Collections'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getCollections(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No collections found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final collection = snapshot.data![index];
                return ListTile(
                  title: Text(collection['id']),
                  subtitle: Text('Documents: ${collection['length']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollectionDetailScreen(
                            collectionId: collection['id']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CollectionDetailScreen extends StatelessWidget {
  final String collectionId;

  CollectionDetailScreen({required this.collectionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collection: $collectionId'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collectionId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No documents found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final document = snapshot.data!.docs[index];
                final data = document.data() as Map<String, dynamic>;
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(document.id,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: _buildFieldDisplay(entry),
                        );
                      }).toList(),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditDocumentDialog(context, document);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteDocument(document);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddDocumentDialog(context);
        },
      ),
    );
  }

  Widget _buildFieldDisplay(MapEntry<String, dynamic> entry) {
    // Handle different types of data
    if (entry.key.contains("image") && entry.value is String) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${entry.key}:'),
          SizedBox(height: 5),
          Image.network(entry.value, height: 150),
        ],
      );
    } else if (entry.key.contains("pdf") && entry.value is String) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${entry.key}:'),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              _launchURL(entry.value);
            },
            child: Text('Open PDF'),
          ),
        ],
      );
    } else if (entry.key.contains("url") && entry.value is String) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${entry.key}:'),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              _launchURL(entry.value);
            },
            child: Text('Open Link'),
          ),
        ],
      );
    } else if (entry.value is Timestamp) {
      // Handle Timestamp
      DateTime dateTime = (entry.value as Timestamp).toDate();
      String formattedDateTime =
          DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
      return Text('${entry.key}: $formattedDateTime');
    } else {
      return Text('${entry.key}: ${entry.value}');
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showAddDocumentDialog(BuildContext context) {
    final Map<String, TextEditingController> _controllers = {};
    final Map<String, String> _data = {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Document'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Field Key'),
                  onSubmitted: (key) {
                    setState(() {
                      _controllers[key] = TextEditingController();
                      _data[key] = "";
                    });
                  },
                ),
                ..._controllers.keys.map((key) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildInputField(key, _controllers[key]!, setState),
                  );
                }).toList(),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final Map<String, dynamic> newData = {};
              _controllers.forEach((key, controller) {
                newData[key] = controller.text;
              });
              _addDocument(newData);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      String key, TextEditingController controller, StateSetter setState) {
    if (key.contains("image") || key.contains("pdf")) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: key),
              readOnly: true,
            ),
          ),
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: key.contains("image") ? FileType.image : FileType.custom,
                allowedExtensions: key.contains("pdf") ? ['pdf'] : null,
              );
              if (result != null) {
                String filePath = result.files.single.path!;
                setState(() {
                  controller.text =
                      filePath; // Just for UI update, you'll handle actual upload separately
                });
              }
            },
          ),
        ],
      );
    } else {
      return TextField(
        controller: controller,
        decoration: InputDecoration(labelText: key),
      );
    }
  }

  void _showEditDocumentDialog(
      BuildContext context, DocumentSnapshot document) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final Map<String, TextEditingController> _controllers = {};

    data.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value?.toString());
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Document: ${document.id}'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: data.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildInputField(
                      entry.key, _controllers[entry.key]!, setState),
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final Map<String, dynamic> updatedData = {};
              _controllers.forEach((key, controller) {
                updatedData[key] = controller.text;
              });
              _updateDocument(document.id, updatedData);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _addDocument(Map<String, dynamic> data) async {
    try {
      // Upload files to a storage service and get URLs, if necessary
      final Map<String, dynamic> finalData = await _processFiles(data);

      await FirebaseFirestore.instance.collection(collectionId).add(finalData);
    } catch (e) {
      print('Error adding document: $e');
    }
  }

  Future<Map<String, dynamic>> _processFiles(Map<String, dynamic> data) async {
    final Map<String, dynamic> finalData = {};
    for (var entry in data.entries) {
      if (entry.key.contains("image") || entry.key.contains("pdf")) {
        // Assume the file has been uploaded and URL is returned
        finalData[entry.key] = entry.value; // Replace with the URL after upload
      } else {
        finalData[entry.key] = entry.value;
      }
    }
    return finalData;
  }

  void _updateDocument(String documentId, Map<String, dynamic> data) async {
    try {
      final Map<String, dynamic> finalData = await _processFiles(data);

      await FirebaseFirestore.instance
          .collection(collectionId)
          .doc(documentId)
          .set(finalData);
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  void _deleteDocument(DocumentSnapshot document) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionId)
          .doc(document.id)
          .delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}
