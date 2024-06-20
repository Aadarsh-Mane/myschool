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
  File? _pdfFile;
  String? _pdfUrl;

  final picker = ImagePicker();

  Future pickPDF() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (pickedFile != null) {
      setState(() {
        _pdfFile = File(pickedFile.files.single.path!);
      });
    }
  }

  Future uploadPDF() async {
    if (_pdfFile == null) return;

    try {
      final fileName = basename(_pdfFile!.path);
      final destination = 'pdfs/$fileName';

      Reference storageReference =
          FirebaseStorage.instance.ref().child(destination);

      UploadTask uploadTask = storageReference.putFile(_pdfFile!);

      await uploadTask.whenComplete(() async {
        setState(() async {
          _pdfUrl = await storageReference.getDownloadURL();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void _addDocument() async {
    if (_pdfUrl == null) {
      // Show a snackbar to inform the user to upload PDF first
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
        content: Text('Please upload PDF first.'),
      ));
      return;
    }

    FirebaseFirestore.instance.collection('econtent').add({
      'name': nameController.text,
      'description': descriptionController.text,
      'pdf_url': _pdfUrl,
    }).then((value) {
      // Document added successfully
      print('Document added successfully!');
      // Clear the text fields
      nameController.clear();
      descriptionController.clear();
      setState(() {
        _pdfFile = null;
        _pdfUrl = null;
      });
    }).catchError((error) {
      // Error occurred
      print('Failed to add document: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: pickPDF,
              child: Text('Select PDF'),
            ),
            SizedBox(height: 16.0),
            _pdfFile != null
                ? Text(
                    'Selected PDF: ${basename(_pdfFile!.path)}',
                    style: TextStyle(fontSize: 16.0),
                  )
                : SizedBox(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: uploadPDF,
              child: Text('Upload PDF'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addDocument,
              child: Text('Add Document'),
            ),
          ],
        ),
      ),
    );
  }
}
