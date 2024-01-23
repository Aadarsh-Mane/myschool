import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Our Team'),
      ),
      body: ListView(
        padding: EdgeInsets.all(50),
        children: [
          OfficePositionCard(
            role: 'Software Engineer',
            experience: '3 years',
            qualification: 'Bachelor\'s in Computer Science',
            imageUrl:
                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg',
          ),
          SizedBox(height: 16),
          OfficePositionCard(
            role: 'Marketing Manager',
            experience: '5 years',
            qualification: 'Master\'s in Marketing',
            imageUrl:
                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg',
          ),
          SizedBox(height: 16),
          OfficePositionCard(
            role: 'Human Resources Specialist',
            experience: '2 years',
            qualification: 'Bachelor\'s in Human Resources',
            imageUrl:
                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg',
          ),
        ],
      ),
    );
  }
}

class OfficePositionCard extends StatelessWidget {
  final String role;
  final String experience;
  final String qualification;
  final String imageUrl;

  const OfficePositionCard({
    required this.role,
    required this.experience,
    required this.qualification,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8),
            Text(
              'Role: $role',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Experience: $experience'),
            SizedBox(height: 8),
            Text('Qualification: $qualification'),
          ],
        ),
      ),
    );
  }
}
