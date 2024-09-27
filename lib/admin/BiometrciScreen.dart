import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';

class BiometricRegistrationScreen extends StatefulWidget {
  @override
  _BiometricRegistrationScreenState createState() =>
      _BiometricRegistrationScreenState();
}

class _BiometricRegistrationScreenState
    extends State<BiometricRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;
  late String email, fullName, phoneNumber, password;

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ));
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance
            .collection('biometric_users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'biometricEnabled': true,
        });

        _showBiometricLockScreen(userCredential.user!);
      } on FirebaseAuthException catch (e) {
        _showErrorSnackbar(e.message ?? 'Registration failed');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showErrorSnackbar('Please fill in all fields.');
    }
  }

  Future<void> _showBiometricLockScreen(User user) async {
    bool didAuthenticate = await _authenticateWithBiometrics();
    if (didAuthenticate) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      _showErrorSnackbar('Biometric authentication failed');
      // Optionally, you can handle retry logic or show a different screen.
    }
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'Please authenticate to continue', // Explanation for biometric authentication
        // useErrorDialogs: true, // Use system's default error dialogs if necessary
        // stickyAuth: true, // Keeps the authentication alive indefinitely until revoked
      );

      return didAuthenticate;
    } catch (e) {
      _showErrorSnackbar('Error during biometric authentication: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biometric Registration'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTextField('Enter Email', (value) {
                    email = value;
                  }),
                  _buildTextField('Enter Full Name', (value) {
                    fullName = value;
                  }),
                  _buildTextField('Enter Phone Number', (value) {
                    phoneNumber = value;
                  }),
                  _buildTextField(
                    'Password',
                    (value) {
                      password = value;
                    },
                    // obscureText: true
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('Register'),
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        obscureText: obscureText,
        validator: (value) {
          if (value!.isEmpty) {
            return 'This field must not be empty';
          }
          return null;
        },
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Text('Welcome to the Home Screen!'),
      ),
    );
  }
}
