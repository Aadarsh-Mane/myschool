import 'package:flutter/material.dart';
import 'package:myschool/RegisterScreen.dart';
import 'package:myschool/pages/YoutubePage.dart';
import 'package:myschool/pages/home_page.dart';
import 'package:myschool/pages/shared/Classes_info.dart';
import 'package:myschool/pages/time_table_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({Key? key}) : super(key: key);

  @override
  _ButtonPageState createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  bool _isAdminLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAdminLoginStatus(); // Check admin login status on widget initialization
  }

  // Function to check admin login status using SharedPreferences
  void _checkAdminLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isAdminLoggedIn') ?? false;
    setState(() {
      _isAdminLoggedIn = isLoggedIn;
    });
  }

  // Function to handle admin logout
  void _adminLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdminLoggedIn', false); // Clear login state
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BuyerRegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Page'),
        backgroundColor: Colors.blue, // Customize app bar color
        actions: [
          if (_isAdminLoggedIn) // Show logout button if admin is logged in
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _adminLogout,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Button color
                onPrimary: Colors.white, // Text color
              ),
              child: const Text('Announcements'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TimetablePage()));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange, // Button color
                onPrimary: Colors.white, // Text color
              ),
              child: const Text('Time Table'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => YoutubePage()));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Button color
                onPrimary: Colors.white, // Text color
              ),
              child: const Text('Events'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action for the fourth button
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Button color
                onPrimary: Colors.white, // Text color
              ),
              child: const Text('Notice'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action for the fifth button
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.purple, // Button color
                onPrimary: Colors.white, // Text color
              ),
              child: const Text(''),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ClassInfoScreen()));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.teal, // Button color
                onPrimary: Colors.white, // Text color
              ),
              child: const Text('Add Homework/Assignment/Info'),
            ),
          ],
        ),
      ),
    );
  }
}
