import 'package:flutter/material.dart';
import 'package:myschool/pages/SpecificHomeWork/EigthClass.dart';

class ClassInfoScreen extends StatelessWidget {
  const ClassInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Four Button Screen'),
        backgroundColor: Colors.deepPurple, // Custom app bar color
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EigthClass()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Button color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(vertical: 16), // Button padding
                ),
                child: const Text(
                  'Eigth Class',
                  style: TextStyle(fontSize: 18), // Button text style
                ),
              ),
              const SizedBox(height: 20), // Vertical spacing
              ElevatedButton(
                onPressed: () {
                  // Action for the second button
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Button color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(vertical: 16), // Button padding
                ),
                child: const Text(
                  'Button 2',
                  style: TextStyle(fontSize: 18), // Button text style
                ),
              ),
              const SizedBox(height: 20), // Vertical spacing
              ElevatedButton(
                onPressed: () {
                  // Action for the third button
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange, // Button color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(vertical: 16), // Button padding
                ),
                child: const Text(
                  'Button 3',
                  style: TextStyle(fontSize: 18), // Button text style
                ),
              ),
              const SizedBox(height: 20), // Vertical spacing
              ElevatedButton(
                onPressed: () {
                  // Action for the fourth button
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Button color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(vertical: 16), // Button padding
                ),
                child: const Text(
                  'Button 4',
                  style: TextStyle(fontSize: 18), // Button text style
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
