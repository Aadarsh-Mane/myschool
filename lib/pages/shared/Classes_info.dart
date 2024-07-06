import 'package:flutter/material.dart';
import 'package:myschool/pages/SpecificHomeWork/EigthClass.dart';
import 'package:myschool/pages/shared/SpecifcClass.dart';

class ClassInfoScreen extends StatelessWidget {
  const ClassInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Information'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildClassButton(context, ' 1st standard', 'one'),
                const SizedBox(height: 20),
                _buildClassButton(context, '2nd standard', 'two'),
                const SizedBox(height: 20),
                _buildClassButton(context, '3rd standard', 'three'),
                const SizedBox(height: 20),
                _buildClassButton(context, ' 4th standard', 'four'),
                const SizedBox(height: 20),
                _buildClassButton(context, ' 5th standard', 'five'),
                const SizedBox(height: 20),
                _buildClassButton(context, ' 6th standard', 'six'),
                const SizedBox(height: 20),
                _buildClassButton(context, ' 7th standard', 'seven'),
                const SizedBox(height: 20),
                _buildClassButton(context, '8th standard ', 'eigth'),
                const SizedBox(height: 20),
                _buildClassButton(context, '9th standard ', 'ninth'),
                const SizedBox(height: 20),
                _buildClassButton(context, '10th standard ', 'tenth'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassButton(
      BuildContext context, String className, String collectionName) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassScreen(
                  className: className, collectionName: collectionName),
            ));
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        onPrimary: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        className,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
