import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ClassScreen extends StatefulWidget {
  final String className;
  final String collectionName;

  ClassScreen({required this.className, required this.collectionName});

  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker picker = ImagePicker(); // ImagePicker instance

  String _selecteddivison = 'All';
  String? _selectedDocumentId;
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = []; // URLs of uploaded images
  bool _uploadingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selecteddivison,
              onChanged: (String? newValue) {
                setState(() {
                  _selecteddivison = newValue!;
                });
              },
              items: <String>['All', 'A', 'B', 'C', 'D', 'E', 'F']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickMultipleImages,
              child: Text('Pick Images'),
            ),
            SizedBox(height: 10),
            // Display selected images if any
            _selectedImages.isNotEmpty
                ? SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              Image.file(
                                _selectedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : Container(),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_selectedDocumentId == null) {
                      _addData();
                    } else {
                      _updateData(_selectedDocumentId!);
                    }
                  },
                  child: Text(
                      _selectedDocumentId == null ? 'Add Data' : 'Update Data'),
                ),
                SizedBox(width: 10),
                if (_uploadingImage) CircularProgressIndicator(),
              ],
            ),
            SizedBox(height: 20),
            _buildDataList(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMultipleImages() async {
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  Future<void> _addData() async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      setState(() {
        _uploadingImage = true;
      });

      _uploadedImageUrls = await _uploadImages();

      await _firestore.collection(widget.collectionName).add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'divison': _selecteddivison,
        'images': _uploadedImageUrls,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selecteddivison = 'All';
        _selectedImages.clear();
        _uploadingImage = false;
      });
    }
  }

  Future<void> _updateData(String documentId) async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      setState(() {
        _uploadingImage = true;
      });

      _uploadedImageUrls = await _uploadImages();

      Map<String, dynamic> updatedData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'divison': _selecteddivison,
        'images': _uploadedImageUrls,
      };

      await _firestore
          .collection(widget.collectionName)
          .doc(documentId)
          .update(updatedData);

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selecteddivison = 'All';
        _selectedDocumentId = null;
        _selectedImages.clear();
        _uploadingImage = false;
      });
    }
  }

  Widget _buildDataList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection(widget.collectionName).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          var data = snapshot.data?.docs;

          return ListView.builder(
            itemCount: data?.length,
            itemBuilder: (context, index) {
              var document = data?[index];
              var title = document?['title'];
              var description = document?['description'];
              var divison = document?['divison'];
              var imageUrls = List<String>.from(document?['images'] ?? []);

              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description),
                      Text('divison: $divison'),
                      SizedBox(height: 8),
                      // Display uploaded images if any
                      imageUrls.isNotEmpty
                          ? SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imageUrls.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        imageUrls[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteData(document!.id);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _selectDocumentForUpdate(
                              document!.id, title, description, divison);
                        },
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

  void _viewImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imageUrl,
              height: 400,
              width: 300,
              fit: BoxFit.cover,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    for (var imageFile in _selectedImages) {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() => null);
      var downloadUrl = await storageRef.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

  Future<void> _deleteData(String documentId) async {
    await _firestore.collection(widget.collectionName).doc(documentId).delete();
  }

  void _selectDocumentForUpdate(
      String documentId, String title, String description, String divison) {
    setState(() {
      _selectedDocumentId = documentId;
      _titleController.text = title;
      _descriptionController.text = description;
      _selecteddivison = divison;
    });
  }
}
