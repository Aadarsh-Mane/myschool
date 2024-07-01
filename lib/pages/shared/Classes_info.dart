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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildClassButton(context, 'Eigth Class', 'Eight'),
              const SizedBox(height: 20),
              _buildClassButton(context, 'Ninth Class', 'Nine'),
              const SizedBox(height: 20),
              _buildClassButton(context, 'Tenth Class', 'Ten'),
              const SizedBox(height: 20),
              _buildClassButton(context, 'Eleventh Class', 'Eleven'),
            ],
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
