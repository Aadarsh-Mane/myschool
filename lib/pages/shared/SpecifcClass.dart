import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
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

  String _selectedOption = 'All';
  String? _selectedDocumentId;
  File? _selectedImage;
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
              value: _selectedOption,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOption = newValue!;
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
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            _selectedImage != null ? Image.file(_selectedImage!) : Container(),
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;

      img.Image resizedImage = img.copyResize(image, width: 200, height: 200);

      final resizedImageFile = File(pickedFile.path)
        ..writeAsBytesSync(img.encodeJpg(resizedImage));

      setState(() {
        _selectedImage = resizedImageFile;
      });
    }
  }

  Future<void> _addData() async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      setState(() {
        _uploadingImage = true;
      });

      String? imageUrl = await _uploadImage();

      await _firestore.collection(widget.collectionName).add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'option': _selectedOption,
        'image': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedOption = 'All';
        _selectedImage = null;
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

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      Map<String, dynamic> updatedData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'option': _selectedOption,
      };

      if (imageUrl != null) {
        updatedData['image'] = imageUrl;
      }

      await _firestore
          .collection(widget.collectionName)
          .doc(documentId)
          .update(updatedData);

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedOption = 'All';
        _selectedDocumentId = null;
        _selectedImage = null;
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
              var option = document?['option'];
              var imageUrl = document?['image'];

              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description),
                      Text('Option: $option'),
                      imageUrl != null
                          ? GestureDetector(
                              onTap: () {
                                _viewImage(imageUrl);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imageUrl,
                                  height: 120,
                                  width: 80,
                                ),
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
                              document!.id, title, description, option);
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

  Future<String> _uploadImage() async {
    if (_selectedImage == null) return '';

    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final UploadTask uploadTask = storageRef.putFile(_selectedImage!);
    await uploadTask.whenComplete(() => null);

    return await storageRef.getDownloadURL();
  }

  Future<void> _deleteData(String documentId) async {
    await _firestore.collection(widget.collectionName).doc(documentId).delete();
  }

  void _selectDocumentForUpdate(
      String documentId, String title, String description, String option) {
    setState(() {
      _selectedDocumentId = documentId;
      _titleController.text = title;
      _descriptionController.text = description;
      _selectedOption = option;
    });
  }
}
