import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myschool/BottomBar.dart';
import 'package:myschool/ChatBot.dart';
import 'package:myschool/user/CollectionScreen.dart';
import 'package:myschool/user/YoutubeWatchScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _userName = ''; // State variable to hold the user's name

  List<String> collectionNames = [
    'notes',
    'timetable',
    'data',
    'events',
    'ninea',
    // 'homie'
  ]; // Add more collection names as needed
  Map<String, int> notificationCounts = {};

  @override
  void initState() {
    super.initState();
    getUserFullName();
    updateNotificationCounts();
  }

  Future<void> getUserFullName() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('buyers').doc(uid).get();

      setState(() {
        _userName =
            snapshot['fullName']; // Update _userName with the user's full name
      });
    } catch (e) {
      print('Error fetching user information: $e');
    }
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
      // appBar: AppBar(
      //   title: Center(child: Text("dxxsx")),
      // ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5EEE6),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                // const SizedBox(width: 300),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: Text('Hello, $_userName!', // Display the user's name
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.cyan)),
                  subtitle: Text('Welcome to HORIZON',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.cyan[300])),
                  trailing: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/logot.png'),
                  ),
                ),
                const SizedBox(height: 30)
              ],
            ),
          ),
          Container(
            // color: Theme.of(context).primaryColor,
            color: Color(0xFFF5EEE6),

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(200))),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 40,
                mainAxisSpacing: 30,
                children: [
                  itemDashboard(
                      'Events', Icons.event, Colors.deepOrange, 'notes'),
                  itemDashboard(
                      'TimeTable', Icons.schedule, Colors.green, 'timetable'),
                  itemDashboard('Latest', Icons.person, Colors.purple, 'notes'),
                  itemDashboard(
                      'Announcement', Icons.chat, Colors.brown, 'notes'),
                  itemDashboard(
                      'E-content', Icons.article, Colors.blue, 'data'),
                  // Add more items as needed
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // BottomBar()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context)
              .push(PageRouteBuilder(pageBuilder: (context, animation, _) {
            return MyChatScreen();
          }));
        },
        child: Icon(Icons.add, color: Colors.blue),
      ),
    );
  }

  Widget itemDashboard(String title, IconData iconData, Color background,
      String collectionName) {
    int notificationCount = notificationCounts[collectionName] ?? 0;

    return GestureDetector(
      onTap: () {
        // Handle tap, e.g., navigate to a new screen with the collection data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CollectionDataScreen(collectionName: collectionName),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: Colors.white),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                'Unread: $notificationCount',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
