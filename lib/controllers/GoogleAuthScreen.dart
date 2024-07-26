import 'package:flutter/material.dart';
import 'package:myschool/services/auth_service.dart';

class GoogleAuthScreen extends StatelessWidget {
  const GoogleAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            AuthService().signInWithGoogle();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.signal_wifi_connected_no_internet_4),
              SizedBox(width: 8),
              Text('Sign In with Google'),
            ],
          ),
        ),
      ),
    );
  }
}
