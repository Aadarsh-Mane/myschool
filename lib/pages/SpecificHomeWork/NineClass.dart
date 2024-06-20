import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class NineClass extends StatefulWidget {
  @override
  _NineClassState createState() => _NineClassState();
}

class _NineClassState extends State<NineClass> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedOption = 'All'; // Default value for dropdown
  String?
      _selectedDocumentId; // Keep track of the selected document for updating
  File? _selectedImage;
  bool _uploadingImage = false; // Flag to track image upload status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Firebase CRUD'),
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
              onPressed: () {
                _pickImage();
              },
              child: Text('Pick Image'),
            ),
            _selectedImage != null
                ? Image.file(_selectedImage!)
                : Container(), // Display selected image if any
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
                // Display circular progress indicator while uploading image
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
      // Read the picked image
      final File imageFile = File(pickedFile.path);
      img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;

      // Resize the image (adjust dimensions as needed)
      img.Image resizedImage = img.copyResize(image, width: 200, height: 200);

      // Save the resized image back to a file
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
        _uploadingImage = true; // Start image upload indicator
      });

      String? imageUrl = await _uploadImage();

      await _firestore.collection('nineth').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'option': _selectedOption,
        'image': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear text fields after adding data
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedOption = 'All';
        _selectedImage = null; // Reset selected image after adding data
        _uploadingImage = false; // Stop image upload indicator
      });
    }
  }

  Future<void> _updateData(String documentId) async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      setState(() {
        _uploadingImage = true; // Start image upload indicator
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

      await _firestore.collection('nineth').doc(documentId).update(updatedData);

      // Clear text fields after updating data
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedOption =
            'All'; // Reset dropdown to default after updating data
        _selectedDocumentId = null; // Reset selected document ID after updating
        _selectedImage = null; // Reset selected image after adding data
        _uploadingImage = false; // Stop image upload indicator
      });
    }
  }

  Widget _buildDataList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('nineth').snapshots(),
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
                                  width: 80, // Adjust the height as needed
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
    await _firestore.collection('nineth').doc(documentId).delete();
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
