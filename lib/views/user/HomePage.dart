import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myschool/BottomBar.dart';
import 'package:myschool/ChatBot.dart';
import 'package:myschool/views/pages/my_page_button.dart';
import 'package:myschool/controllers/UserProvider.dart';
import 'package:myschool/views/user/CollectionScreen.dart';
import 'package:myschool/views/user/YoutubeWatchScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> collectionNames = [
    'notes',
    'timetable',
    'econtent',
    'events',
    'ninea',
  ]; // Add more collection names as needed
  Map<String, int> notificationCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    updateNotificationCounts();
  }

  Future<void> _fetchUserInfo() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        // Get full name and image URL from Firestore
        String fullName = snapshot['fullName'];
        String imageUrl = snapshot['imageUrl'];

        // Update the UserProvider
        Provider.of<UserProvider>(context, listen: false)
            .setUserInfo(fullName, imageUrl);
      }
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
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5EEE6),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.1),
                      title: Text(
                        'Hello, ${userProvider.fullName}!',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.cyan),
                      ),
                      subtitle: Text(
                        'Welcome to HORIZON',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.cyan[300]),
                      ),
                      trailing: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: MediaQuery.of(context).size.width * 0.1,
                        backgroundImage: userProvider.imageUrl.isNotEmpty
                            ? NetworkImage(userProvider.imageUrl)
                            : AssetImage('assets/images/logot.png')
                                as ImageProvider<Object>,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ],
                ),
              ),
              Container(
                color: Color(0xFFF5EEE6),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logot.png'),
                      fit: BoxFit.cover,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          MediaQuery.of(context).size.width * 0.2),
                    ),
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount:
                        MediaQuery.of(context).size.width < 600 ? 2 : 4,
                    crossAxisSpacing:
                        MediaQuery.of(context).size.width < 600 ? 20 : 40,
                    mainAxisSpacing:
                        MediaQuery.of(context).size.width < 600 ? 35 : 30,
                    children: [
                      itemDashboard(
                          'Events', Icons.event, Colors.deepOrange, 'notes'),
                      itemDashboard('TimeTable', Icons.schedule, Colors.green,
                          'timetable'),
                      itemDashboard(
                          'Latest', Icons.person, Colors.purple, 'notes'),
                      itemDashboard(
                          'Attendes', Icons.chat, Colors.brown, 'absences'),
                      itemDashboard(
                          'E-content', Icons.article, Colors.blue, 'econtent'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.03,
            right: MediaQuery.of(context).size.width * 0.03,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.03),
                  ),
                  onPressed: () {
                    _showLoginDialog(context);
                  },
                  child: Icon(Icons.admin_panel_settings, size: 30),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                        PageRouteBuilder(pageBuilder: (context, animation, _) {
                      return MyMyMyChatScreen();
                    }));
                  },
                  child: Icon(Icons.add, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget itemDashboard(String title, IconData iconData, Color background,
      String collectionName) {
    int notificationCount = notificationCounts[collectionName] ?? 0;

    return GestureDetector(
      onTap: () {
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
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: Colors.white),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.cyan[300]),
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.005),
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

  void _showLoginDialog(BuildContext context) {
    TextEditingController idController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (BuildContext context, Animation firstAnimation,
          Animation secondAnimation) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Teacher  Login',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: 'Enter ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Enter Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      if (idController.text.trim() == 'Schoolstaff' &&
                          passwordController.text.trim() == 'Teacher') {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const ButtonPage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invalid ID or Password'),
                          ),
                        );
                      }
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
    );
  }
}
