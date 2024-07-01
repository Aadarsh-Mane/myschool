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
    'nineth',
    'Eight'
  ]; // Add more collection names as needed
  Map<String, String> collectionPasswords = {
    'nineth': '1234',
    'Eight': '8b',
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
                  itemDashboard('Class 9th', CupertinoIcons.chat_bubble_2,
                      Colors.brown, 'nineth', '1234'),
                  itemDashboard('Class 8th', CupertinoIcons.chat_bubble_2,
                      Colors.brown, 'Eight', '8b'),
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
                style: Theme.of(context).textTheme.subtitle1),
            SizedBox(height: 4),
            Text(
              'Unread: $notificationCount',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
