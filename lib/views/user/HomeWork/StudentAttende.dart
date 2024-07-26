import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentAttende extends StatefulWidget {
  @override
  _StudentAttendeState createState() => _StudentAttendeState();
}

class _StudentAttendeState extends State<StudentAttende> {
  final _rollNoController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedClass = '1st';
  String _selectedDivision = 'A';

  final _classOptions = ['1st', '2nd', '3rd', '4th'];
  final _divisionOptions = ['A', 'B', 'C'];

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() async {
    final rollNo = _rollNoController.text;
    final name = _nameController.text;
    final absenceDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : '';
    final studentClass = _selectedClass;
    final division = _selectedDivision;

    if (rollNo.isEmpty || name.isEmpty || absenceDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('absences').add({
        'roll_no': rollNo,
        'name': name,
        'absence_date': absenceDate,
        'class': studentClass,
        'division': division,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student data added')),
      );
      _clearFields();
    } catch (e) {
      print('Error adding data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding data: $e')),
      );
    }
  }

  void _clearFields() {
    _rollNoController.clear();
    _nameController.clear();
    setState(() {
      _selectedDate = null;
      _selectedClass = '1st';
      _selectedDivision = 'A';
    });
  }

  void _deleteDocument(String id) async {
    try {
      await FirebaseFirestore.instance.collection('absences').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student data deleted')),
      );
    } catch (e) {
      print('Error deleting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting data: $e')),
      );
    }
  }

  void _editDocument(String id) async {
    final rollNo = _rollNoController.text;
    final name = _nameController.text;
    final absenceDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : '';
    final studentClass = _selectedClass;
    final division = _selectedDivision;

    if (rollNo.isEmpty || name.isEmpty || absenceDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('absences').doc(id).update({
        'roll_no': rollNo,
        'name': name,
        'absence_date': absenceDate,
        'class': studentClass,
        'division': division,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student data updated')),
      );
      _clearFields();
    } catch (e) {
      print('Error updating data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _rollNoController,
              decoration: InputDecoration(labelText: 'Roll Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Student Name'),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date selected!'
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedClass,
              items: _classOptions.map((classOption) {
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
              items: _divisionOptions.map((divisionOption) {
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
            ElevatedButton(
              onPressed: _submit,
              child: Text('Submit'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('absences')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final data = snapshot.data;
                  if (data == null || data.docs.isEmpty) {
                    return Text('No students found.');
                  }

                  // Group data by class and division
                  final Map<String, Map<String, List<DocumentSnapshot>>>
                      groupedData = {};
                  for (var doc in data.docs) {
                    final student = doc.data() as Map<String, dynamic>;
                    final studentClass = student['class'];
                    final division = student['division'];

                    if (!groupedData.containsKey(studentClass)) {
                      groupedData[studentClass] = {};
                    }
                    if (!groupedData[studentClass]!.containsKey(division)) {
                      groupedData[studentClass]![division] = [];
                    }
                    groupedData[studentClass]![division]!.add(doc);
                  }

                  return ListView(
                    children: groupedData.entries.map((classEntry) {
                      return ExpansionTile(
                        title: Text('Class: ${classEntry.key}'),
                        children: classEntry.value.entries.map((divisionEntry) {
                          return ExpansionTile(
                            title: Text('Division: ${divisionEntry.key}'),
                            children: divisionEntry.value.map((doc) {
                              final student =
                                  doc.data() as Map<String, dynamic>;
                              return ListTile(
                                title: Text(student['name']),
                                subtitle: Text(
                                    'Roll No: ${student['roll_no']}, Date: ${student['absence_date']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _rollNoController.text =
                                            student['roll_no'];
                                        _nameController.text = student['name'];
                                        _selectedDate = DateTime.parse(
                                            student['absence_date']);
                                        setState(() {
                                          _selectedClass = student['class'];
                                          _selectedDivision =
                                              student['division'];
                                        });
                                        // Show a dialog or another screen to confirm the changes
                                        // Call _editDocument(doc.id) after confirmation
                                      },
                                    ),

                                    // IconButton(
                                    //   icon: Icon(Icons.edit),
                                    //   onPressed: () {
                                    //     _rollNoController.text =
                                    //         student['roll_no'];
                                    //     _nameController.text = student['name'];
                                    //     _selectedDate = DateTime.parse(
                                    //         student['absence_date']);
                                    //     setState(() {
                                    //       _selectedClass = student['class'];
                                    //       _selectedDivision =
                                    //           student['division'];
                                    //     });
                                    //     _editDocument(doc.id);
                                    //   },
                                    // ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteDocument(doc.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
