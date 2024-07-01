import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myschool/controllers/AuthScreen.dart';
import 'package:myschool/widgets/QrScanner.dart';
import 'package:quickalert/quickalert.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:myschool/BottomBar.dart';
import 'package:myschool/user/LoginScreen.dart';

class UserAlreadyExistsException implements Exception {
  final String message;
  UserAlreadyExistsException(this.message);
}

class BuyerRegisterScreen extends StatefulWidget {
  @override
  State<BuyerRegisterScreen> createState() => _BuyerRegisterScreenState();
}

class _BuyerRegisterScreenState extends State<BuyerRegisterScreen> {
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String email;
  late String fullName;
  late String phoneNumber;
  late String password;
  late String schoolId;
  late String schoolPass;
  String userType = 'Student'; // Default to Student
  XFile? _selectedImage; // To store the selected image
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Proceed to crop the image
      CroppedFile? croppedFile = await ImageCropper()
          .cropImage(sourcePath: image.path, aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ], uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      ]);

      if (croppedFile != null) {
        setState(() {
          _selectedImage = XFile(croppedFile.path);
        });
      }
    }
  }

  _checkAuthentication() async {
    bool isAuthenticated = await _authController.isUserAuthenticated();
    if (isAuthenticated) {
      _showErrorSnackbar('You are already logged in.');
      _navigateToBottomBar();
    }
  }

  _signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      // Check if image is required and selected
      if (userType == 'Student' && _selectedImage == null) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar('Student must upload an image.');
        return;
      }

      // Check School ID and School Pass
      if (schoolId != '123' || schoolPass != 'abc') {
        setState(() {
          _isLoading = false;
        });
        _showQuickAlert();
        return;
      }

      try {
        String imageUrl = '';
        if (_selectedImage != null) {
          imageUrl =
              await _authController.uploadImageToStorage(_selectedImage!);
        }

        String result = await _authController.signUpUsers(
            email, fullName, phoneNumber, password, userType, imageUrl);

        if (result == 'success') {
          setState(() {
            _formKey.currentState!.reset();
            _isLoading = false;
          });

          _navigateToBottomBar();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Registration Completed Successfully!',
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackbar(result);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (e is UserAlreadyExistsException) {
          _showErrorSnackbar('User with this email already exists.');
        } else {
          _showErrorSnackbar('An error occurred: ${e.toString()}');
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Please fill in all fields.');
    }
  }

  _showQuickAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: 'Invalid School ID or School Pass!',
    );
  }

  _navigateToBottomBar() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BottomBar()),
      (route) => false,
    );
  }

  _navigateToLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showErrorSnackbar(String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.fixed,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: message,
        contentType: ContentType.warning,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(),
      ),
    );

    if (result != null) {
      // Handle the result of the QR code scan
      if (result == 'VALID_QR_CODE') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BottomBar(), // The new screen after scanning
          ),
        );
      } else {
        _showErrorSnackbar('Invalid QR Code!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool isAuthenticated = await _authController.isUserAuthenticated();
        return !isAuthenticated;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF5EEE6),
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 100,
                    backgroundImage: AssetImage('assets/images/logot.png'),
                  ),
                  _buildTextField('Enter Email', (value) {
                    email = value;
                  }),
                  _buildTextField('Enter Full Name', (value) {
                    fullName = value;
                  }),
                  _buildTextField('Enter Phone Number', (value) {
                    phoneNumber = value;
                  }),
                  _buildTextField('Password', (value) {
                    password = value;
                  }, obscureText: true),
                  _buildDropdown(), // User type dropdown
                  _buildTextField('School ID', (value) {
                    schoolId = value;
                  }),
                  _buildTextField('School Pass', (value) {
                    schoolPass = value;
                  }, obscureText: true),
                  if (_selectedImage != null)
                    Image.file(File(_selectedImage!.path), height: 100),
                  _buildImagePickerButton(), // Image picker button always shown
                  _buildRegisterButton(),
                  _buildLoginLink(),
                  SizedBox(height: 20), // Add some spacing
                  _buildQRScannerButton(), // Add the QR scanner button
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, Function(String) onChanged,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: TextFormField(
        obscureText: obscureText,
        validator: (value) {
          if (value!.isEmpty) {
            return ''; // Return empty to trigger form validation without showing text.
          } else {
            return null;
          }
        },
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: DropdownButtonFormField<String>(
        value: userType,
        items: ['Student', 'Teacher'].map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            userType = newValue!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Select User Type',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: Icon(Icons.photo_camera), // Example icon, you can change this
        label: Text(_selectedImage == null ? 'Pick Image' : 'Change Image'),
        style: ElevatedButton.styleFrom(
          primary: Colors.orange, // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _signUpUser,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator(
                  color: Colors.white,
                )
              : Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account?'),
        TextButton(
          onPressed: _navigateToLoginScreen,
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRScannerButton() {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: ElevatedButton.icon(
        onPressed: _scanQRCode,
        icon: Icon(Icons.qr_code), // Example icon, you can change this
        label: Text('Admin '),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue, // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
