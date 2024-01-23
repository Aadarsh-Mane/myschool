// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Dashboard',
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//       ),
//       home: const UserHomePage(),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myschool/BottomBar.dart';
import 'package:myschool/ChatBot.dart';
import 'package:myschool/user/CollectionScreen.dart';
import 'package:myschool/user/YoutubeWatchScreen.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  List<String> collectionNames = [
    'notes',
    'timetable',
    'data',
    'events'
    // 'homie'
  ]; // Add more collection names as needed
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
                  title: Text('Hello !',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.cyan)),
                  subtitle: Text('Good Morning',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.cyan[300])),
                  trailing: const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg'),
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
                  itemDashboard('Events', CupertinoIcons.play_rectangle,
                      Colors.deepOrange, 'notes'),
                  itemDashboard('TimeTable', CupertinoIcons.graph_circle,
                      Colors.green, 'timetable'),
                  itemDashboard('Latest', CupertinoIcons.person_2,
                      Colors.purple, 'notes'),
                  itemDashboard('Announce', CupertinoIcons.chat_bubble_2,
                      Colors.brown, 'notes'),
                  itemDashboard('Data', CupertinoIcons.chat_bubble_2,
                      Colors.brown, 'data'),
                  // itemDashboard('Study', CupertinoIcons.money_dollar_circle,
                  //     Colors.indigo, 'notes'),
                  // itemDashboard('Attende', CupertinoIcons.add_circled,
                  //     Colors.teal, 'notes'),
                  // itemDashboard('About', CupertinoIcons.question_circle,
                  //     Colors.blue, 'notes'),
                  // itemDashboard('Contact', CupertinoIcons.phone,
                  //     Colors.pinkAccent, 'notes')
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

  Widget itemDashboard(
    String title,
    IconData iconData,
    Color background,
    String collectionName,
  ) {
    print(collectionName.length);
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
            Text(title.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
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
