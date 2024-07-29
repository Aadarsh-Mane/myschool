import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myschool/views/user/CollectionScreen.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  List<String> collectionNames = [
    'one',
    'two',
    'three',
    'four',
    'six',
    'seven',
    'eight',
    'nine',
    'tenth'
  ]; // Add more collection names as needed
  Map<String, String> collectionPasswords = {
    'one': 'one',
    'two': '1234',
    'three': '1234',
    'four': '1234',
    'six': '1234',
    'seven': '1234',
    'eight:': '1234',
    'nine': '1234',
    'tenth': '1234',
  };

  Map<String, int> notificationCounts = {};

  @override
  void initState() {
    super.initState();
    updateNotificationCounts();
  }

  Future<void> updateNotificationCounts() async {
    for (String collectionName in collectionNames) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();

      setState(() {
        notificationCounts[collectionName] = querySnapshot.docs.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: 20),
        children: [
          Container(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(200)),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 40,
                mainAxisSpacing: 30,
                children: [
                  // itemDashboard('Events', CupertinoIcons.play_rectangle,
                  //     Colors.deepOrange, 'notes', ''),
                  // itemDashboard('Class 9th', CupertinoIcons.info_circle_fill,
                  //     Colors.brown, 'nineth', '1234'),
                  // itemDashboard('Class 8th', CupertinoIcons.info_circle_fill,
                  //     Colors.brown, 'one', '8b'),
                  itemDashboard('1st standard', CupertinoIcons.info_circle_fill,
                      Colors.brown, 'one', 'class1'),
                  itemDashboard('2nd standard', CupertinoIcons.info_circle_fill,
                      Colors.brown, 'two', 'class2'),
                  itemDashboard('3rd standard', CupertinoIcons.info_circle_fill,
                      Colors.brown, 'three', 'class3'),
                  itemDashboard('4th standard', CupertinoIcons.info_circle_fill,
                      Colors.brown, 'four', 'class4'),
                  itemDashboard('5th standard', CupertinoIcons.info_circle_fill,
                      Colors.brown, 'five', 'class5'),
                  itemDashboard('6th standard', CupertinoIcons.info_circle_fill,
                      Colors.brown, 'sixth', 'one'),
                  itemDashboard('7th standard', CupertinoIcons.info_circle_fill,
                      Colors.brown, 'seven', 'one'),
                  itemDashboard('8th standard', CupertinoIcons.info_circle_fill,
                      Colors.brown, 'eigth', 'one'),
                  itemDashboard('9th standard', CupertinoIcons.info_circle_fill,
                      Colors.brown, 'nine', 'one'),
                  itemDashboard(
                      '10th standard',
                      CupertinoIcons.info_circle_fill,
                      Colors.brown,
                      'ten',
                      'one'),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget itemDashboard(
    String title,
    IconData iconData,
    Color background,
    String collectionName,
    String password,
  ) {
    int notificationCount = notificationCounts[collectionName] ?? 0;

    return GestureDetector(
      onTap: () {
        // Show password dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            String enteredPassword =
                ''; // Variable to store the entered password
            return AlertDialog(
              title: Text('Enter Passwordd'),
              content: TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                onChanged: (value) {
                  enteredPassword = value; // Store the entered password
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (enteredPassword == password) {
                      // Password verification logic
                      // Handle tap, e.g., navigate to a new screen with the collection data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CollectionDataScreen(
                            collectionName: collectionName,
                          ),
                        ),
                      );
                    } else {
                      // Show error message for incorrect password
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Incorrect Password'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 5),
              color: Theme.of(context).primaryColor.withOpacity(.2),
              spreadRadius: 10,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(title.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 4),
            Text(
              'Total: $notificationCount',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
