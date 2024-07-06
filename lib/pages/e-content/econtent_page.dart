import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class AddDocumentPage extends StatefulWidget {
  @override
  _AddDocumentPageState createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // For PDFs
  List<File> _pdfFiles = [];
  List<String> _pdfUrls = [];

  // For images
  List<File> _imageFiles = [];
  List<String> _imageUrls = [];

  final picker = ImagePicker();

  // List of standards for the dropdown menu
  final List<String> _standards = ['1st', '2nd', '3rd', '4th', '5th'];
  String? _selectedStandard; // To hold the selected standard

  // Loading state
  bool _isLoading = false;

  // Function to pick multiple PDFs
  Future pickMultiplePDFs() async {
    final pickedFiles = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (pickedFiles != null) {
      setState(() {
        _pdfFiles = pickedFiles.paths.map((path) => File(path!)).toList();
      });
    }
  }

  // Function to pick multiple images
  Future pickMultipleImages() async {
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _imageFiles =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  // Function to upload a file to Firebase Storage
  Future<String> uploadFile(File file, String destination) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child(destination);
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() async {});
      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Upload error: $e');
      return '';
    }
  }

  // Function to upload all PDFs and images
  Future<void> uploadFiles() async {
    _pdfUrls.clear();
    _imageUrls.clear();

    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    // Upload PDFs
    for (File pdf in _pdfFiles) {
      String fileName = basename(pdf.path);
      String pdfUrl = await uploadFile(pdf, 'pdfs/$fileName');
      if (pdfUrl.isNotEmpty) {
        _pdfUrls.add(pdfUrl);
      }
    }

    // Upload Images
    for (File image in _imageFiles) {
      String fileName = basename(image.path);
      String imageUrl = await uploadFile(image, 'images/$fileName');
      if (imageUrl.isNotEmpty) {
        _imageUrls.add(imageUrl);
      }
    }

    // Set loading state to false
    setState(() {
      _isLoading = false;
    });
  }

  // Function to add document to Firestore
  void _addDocument() async {
    await uploadFiles();

    FirebaseFirestore.instance.collection('econtent').add({
      'name': nameController.text,
      'description': descriptionController.text,
      'pdf_urls': _pdfUrls,
      'image_urls': _imageUrls,
      'standard': _selectedStandard, // Include the selected standard
    }).then((value) {
      print('Document added successfully!');
      nameController.clear();
      descriptionController.clear();
      setState(() {
        _pdfFiles.clear();
        _imageFiles.clear();
        _pdfUrls.clear();
        _imageUrls.clear();
        _selectedStandard = null; // Reset the selected standard
      });
    }).catchError((error) {
      print('Failed to add document: $error');
    });
  }

  // Function to update a document in Firestore
  void _updateDocument(String docId) async {
    await uploadFiles();

    FirebaseFirestore.instance.collection('econtent').doc(docId).update({
      'name': nameController.text,
      'description': descriptionController.text,
      'pdf_urls': _pdfUrls,
      'image_urls': _imageUrls,
      'standard': _selectedStandard, // Include the selected standard
    }).then((value) {
      print('Document updated successfully!');
      nameController.clear();
      descriptionController.clear();
      setState(() {
        _pdfFiles.clear();
        _imageFiles.clear();
        _pdfUrls.clear();
        _imageUrls.clear();
        _selectedStandard = null; // Reset the selected standard
      });
    }).catchError((error) {
      print('Failed to update document: $error');
    });
  }

  // Function to delete a document from Firestore
  void _deleteDocument(String docId) {
    FirebaseFirestore.instance
        .collection('econtent')
        .doc(docId)
        .delete()
        .then((value) {
      print('Document deleted successfully!');
    }).catchError((error) {
      print('Failed to delete document: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Documents'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add New Document',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 16.0),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Standard',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedStandard,
                            items: _standards.map((standard) {
                              return DropdownMenuItem(
                                value: standard,
                                child: Text(standard),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStandard = value;
                              });
                            },
                          ),
                          SizedBox(height: 16.0),
                          ElevatedButton.icon(
                            onPressed: pickMultiplePDFs,
                            icon: Icon(Icons.picture_as_pdf),
                            label: Text('Select PDFs'),
                          ),
                          if (_pdfFiles.isNotEmpty) ...[
                            SizedBox(height: 16.0),
                            Text(
                              'Selected PDFs:',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _pdfFiles.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Icon(Icons.picture_as_pdf),
                                  title: Text(basename(_pdfFiles[index].path)),
                                );
                              },
                            ),
                          ],
                          SizedBox(height: 16.0),
                          ElevatedButton.icon(
                            onPressed: pickMultipleImages,
                            icon: Icon(Icons.image),
                            label: Text('Select Images'),
                          ),
                          if (_imageFiles.isNotEmpty) ...[
                            SizedBox(height: 16.0),
                            Text(
                              'Selected Images:',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                              ),
                              itemCount: _imageFiles.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                        _imageFiles[index],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: () {
                                          setState(() {
                                            _imageFiles.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                          SizedBox(height: 16.0),
                          ElevatedButton.icon(
                            onPressed: _addDocument,
                            icon: Icon(Icons.add),
                            label: Text('Add Document'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.0),
                  Text(
                    'Existing Documents',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('econtent')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      final documents = snapshot.data?.docs ?? [];
                      Map<String, List<DocumentSnapshot>> categorizedDocs = {};

                      for (var doc in documents) {
                        String standard = doc['standard'];
                        if (!categorizedDocs.containsKey(standard)) {
                          categorizedDocs[standard] = [];
                        }
                        categorizedDocs[standard]!.add(doc);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: categorizedDocs.entries.map((entry) {
                          String standard = entry.key;
                          List<DocumentSnapshot> docs = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$standard Standard',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    elevation: 3,
                                    child: ListTile(
                                      title: Text(doc['name']),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Description: ${doc['description']}'),
                                          Wrap(
                                            spacing: 8.0,
                                            children: [
                                              ...List<String>.from(
                                                      doc['pdf_urls'] ?? [])
                                                  .map(
                                                (url) => GestureDetector(
                                                  onTap: () => _openURL(url),
                                                  child: Text(
                                                    'PDF Link',
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                              ),
                                              ...List<String>.from(
                                                      doc['image_urls'] ?? [])
                                                  .map(
                                                (url) => GestureDetector(
                                                  onTap: () => _openURL(url),
                                                  child: Image.network(
                                                    url,
                                                    width: 50,
                                                    height: 50,
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              // Populate the fields with document data for editing
                                              setState(() {
                                                nameController.text =
                                                    doc['name'];
                                                descriptionController.text =
                                                    doc['description'];
                                                _selectedStandard =
                                                    doc['standard'];
                                                _pdfUrls = List<String>.from(
                                                    doc['pdf_urls'] ?? []);
                                                _imageUrls = List<String>.from(
                                                    doc['image_urls'] ?? []);
                                                // For now, we do not reload files
                                                _pdfFiles.clear();
                                                _imageFiles.clear();
                                              });
                                              // Call update function when the user submits changes
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Update Document'),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextFormField(
                                                          controller:
                                                              nameController,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText: 'Name',
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        TextFormField(
                                                          controller:
                                                              descriptionController,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Description',
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        DropdownButtonFormField<
                                                            String>(
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Standard',
                                                          ),
                                                          value:
                                                              _selectedStandard,
                                                          items: _standards
                                                              .map((standard) {
                                                            return DropdownMenuItem(
                                                              value: standard,
                                                              child: Text(
                                                                  standard),
                                                            );
                                                          }).toList(),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _selectedStandard =
                                                                  value;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          _updateDocument(
                                                              doc.id);
                                                        },
                                                        child: Text('Update'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () =>
                                                _deleteDocument(doc.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 16.0),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  // Function to open URLs
  void _openURL(String url) {
    // Implement URL opening functionality here
    print('Opening URL: $url');
  }
}
