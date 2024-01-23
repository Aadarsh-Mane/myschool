import 'package:flutter/material.dart';
import 'package:myschool/BottomBar.dart';
import 'package:myschool/Snack.dart';
import 'package:myschool/controllers/AuthScreen.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Check if the user is already authenticated when the screen is initialized
    _checkAuthentication();
  }

  _checkAuthentication() async {
    bool isAuthenticated = await _authController.isUserAuthenticated();

    if (isAuthenticated) {
      // User is already authenticated, navigate to BottomBar
      _navigateToBottomBar();
    }
  }

  _signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      await _authController
          .signUpUSers(email, fullName, phoneNumber, password)
          .whenComplete(() {
        setState(() {
          _formKey.currentState!.reset();
          _isLoading = false;
        });

        // Navigate to the BottomBar screen after successful registration
        _navigateToBottomBar();

        showSnack(context, 'Congratulations! Your account has been created.');
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnack(context, 'Please fill in all fields.');
    }
  }

  _navigateToBottomBar() {
    // Navigate to the BottomBar screen and remove the registration screen from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BottomBar()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Disable back button functionality when the user is logged in
      onWillPop: () async {
        bool isAuthenticated = await _authController.isUserAuthenticated();
        return !isAuthenticated;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF5EEE6), // Background color
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Your UI code goes here
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
                  _buildRegisterButton(),
                  _buildLoginLink(),
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
            return 'This field must not be empty';
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

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _signUpUser,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.orange, // Custom button color
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator(
                  color: Colors.white,
                )
              : TextButton(
                  onPressed: _navigateToBottomBar,
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
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
          onPressed: _navigateToBottomBar, // Change this to your login logic
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
}
