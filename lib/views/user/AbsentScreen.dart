import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AbsentScreen extends StatefulWidget {
  @override
  _AbsentScreenState createState() => _AbsentScreenState();
}

class _AbsentScreenState extends State<AbsentScreen> {
  // final _passwordController = TextEditingController();
  var _selectedClass = '1st';
  var _selectedDivision = 'A';

  void _submitPassword() {
    // Handle password validation here
    // For demonstration, we assume all passwords are 'password'
    // if (_passwordController.text == 'password') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AbsenceListScreen(
          studentClass: _selectedClass,
          division: _selectedDivision,
        ),
      ),
    );
    // } else {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(SnackBar(content: Text('Incorrect password')));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Absences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedClass,
              items: ['1st', '2nd', '3rd', '4th'].map((classOption) {
                return DropdownMenuItem(
                  value: classOption,
                  child: Text(classOption),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClass = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Class'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedDivision,
              items: ['A', 'B', 'C'].map((divisionOption) {
                return DropdownMenuItem(
                  value: divisionOption,
                  child: Text(divisionOption),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDivision = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Division'),
            ),
            SizedBox(height: 16.0),
            // TextField(
            //   controller: _passwordController,
            //   decoration: InputDecoration(labelText: 'Enter Password'),
            //   obscureText: true,
            // ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitPassword,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class AbsenceListScreen extends StatelessWidget {
  final String studentClass;
  final String division;

  AbsenceListScreen({
    required this.studentClass,
    required this.division,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Absence List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('absences')
            .where('class', isEqualTo: studentClass)
            .where('division', isEqualTo: division)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No absences found.'));
          }

          final absences = snapshot.data!.docs;

          return ListView.builder(
            itemCount: absences.length,
            itemBuilder: (context, index) {
              final absence = absences[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(absence['name']),
                subtitle: Text(
                    'Roll No: ${absence['roll_no']} - Date: ${absence['absence_date']}'),
              );
            },
          );
        },
      ),
    );
  }
}
