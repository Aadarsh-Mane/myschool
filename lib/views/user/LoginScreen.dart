import 'package:flutter/material.dart';
import 'package:myschool/BottomBar.dart';
import 'package:myschool/Snack.dart';
import 'package:myschool/controllers/AuthScreen.dart';
import 'package:myschool/introScreen/SplashScreen.dart';
import 'package:quickalert/quickalert.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  bool _isLoading = false;

  _showErrorSnackbar(String message) {
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

  _loginUser() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      String result = await _authController.loginUsers(email, password);

      if (result == 'success') {
        _navigateToBottomBar();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Login Completed !',
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnack(context, result);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _navigateToBottomBar() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EEE6),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor:
                      Colors.transparent, // Set background color to transparent

                  radius: 120, // Adjust the radius as needed
                  backgroundImage: AssetImage(
                      'assets/images/logot.png'), // Path to your logo
                ),
                SizedBox(height: 20),
                _buildTextField('Enter Email', (value) {
                  email = value;
                }),
                _buildTextField('Password', (value) {
                  password = value;
                }, obscureText: true),
                _buildLoginButton(),
              ],
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
          if (value!.trim().isEmpty) {
            _showErrorSnackbar('Please fill in all fields.');

            return '';
          } else {
            return null;
          }
        },
        onChanged: (value) {
          onChanged(value.trim()); // Call onChanged with trimmed value
        },
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _loginUser,
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
                  'Login',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
