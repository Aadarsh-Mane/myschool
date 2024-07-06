import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myschool/BottomBar.dart';
import 'package:myschool/RegisterScreen.dart';
import 'package:myschool/controllers/AuthScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthController _authController =
      AuthController(); // Instance of AuthController
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _checkAuthentication();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _checkAuthentication() async {
    bool isAuthenticated = await _authController.isUserAuthenticated();

    // Navigate based on authentication status
    if (isAuthenticated) {
      // User is authenticated, navigate to main screen
      _navigateToMainScreen();
    } else {
      // User is not authenticated, navigate to registration screen
      _navigateToRegistrationScreen();
    }
  }

  void _navigateToRegistrationScreen() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BuyerRegisterScreen()),
      );
    });
  }

  void _navigateToMainScreen() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BottomBar()), // Adjust as per your main screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/images/logot.png', // Replace with your icon path
            width: 150, // Adjust as needed
            height: 150, // Adjust as needed
          ),
        ),
      ),
    );
  }
}
