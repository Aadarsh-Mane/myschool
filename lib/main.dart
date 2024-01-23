import 'dart:developer';

import 'package:concentric_transition/concentric_transition.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:myschool/Aboutus.dart';
import 'package:myschool/AddData.dart';
import 'package:myschool/BottomBar.dart';
import 'package:myschool/ChatBot.dart';
import 'package:myschool/Dictionary.dart';
import 'package:myschool/Meaning.dart';
import 'package:myschool/RegisterScreen.dart';
import 'package:myschool/controllers/GoogleAuthScreen.dart';
import 'package:myschool/floaf.dart';
import 'package:myschool/introScreen/IntroScreen.dart';

import 'package:myschool/pages/CalenderEvent.dart';
import 'package:myschool/pages/HomeWork.dart';
import 'package:myschool/pages/home_page.dart';
import 'package:myschool/pages/my_page_button.dart';
import 'package:myschool/user/CalenderEvent.dart';
import 'package:myschool/user/HomePage.dart';
import 'package:myschool/user/TimeTableScreen.dart';
import 'package:myschool/user/YoutubeWatchScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 152, 208, 212)),
        useMaterial3: true,
      ),
      // home: const ButtonPage(),
      // home: YoutubeListPage(),
      // home: BottomBar(),
      // home: GoogleAuthScreen()
      // home: AboutUsScreen(),
      // home: UserChatScreen()
      // home: const BottomBar(),
      // home: MeaningScreen1()
      // home: TimeTableScreen(),
      // home: MyHomePage(),
      home: const ConcentricTransitionPage(),
      // home: UserCalendarScreen()
      // home: UserCalendarScreen()
      // home: HomeWork()
      // home: UserHomePage(),
      //  home: AuthScreen(),
      // home: SignUpScreen(),
      // home: BuyerRegisterScreen()
      // home: YoutubeListPage(),
    );
  }
}

class SideBar extends StatefulWidget {
  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Widget page = MainScreen();

  // const SideBar({super.key});
  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      menuScreen: Builder(builder: (context) {
        return MenuScreen(
          onPageChanged: (a) {
            setState(() {
              if (a is Widget) {
                page = a;
              }
            });
            ZoomDrawer.of(context)!.close();
          },
        );
      }),
      mainScreen: page,
      borderRadius: 24.0,
      showShadow: true,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Color(0xFFF5EEE6),

        // leading: IconButton(
        //     icon: Icon(Icons.menu),
        //     onPressed: () => ZoomDrawer.of(context)!.toggle()),
      ),
      body: UserHomePage(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  MenuScreen({Key? key, required this.onPageChanged}) : super(key: key);
  final Function(Widget) onPageChanged;
  List<ListItems> drawerItems = [
    // ListItems(Icon(Icons.payment), Text('payment'), UserHomePage()),
    ListItems(Icon(Icons.payment), Text('About'), AboutUsScreen()),
    ListItems(
        Icon(Icons.ice_skating_rounded), Text('Level Up'), MeaningScreen()),
    ListItems(
        Icon(Icons.ice_skating_rounded), Text('Events'), UserCalendarScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Theme(
          data: ThemeData.dark(),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: drawerItems
                  .map((e) => ListTile(
                        onTap: () {
                          onPageChanged(e.page);
                        },
                        title: e.title,
                        leading: e.icon,
                      ))
                  .toList())),
    );
  }
}

class ListItems {
  final Icon icon;
  final Text title;
  final Widget page;
  ListItems(this.icon, this.title, this.page);
}

class Item1Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item 1 Page'),
        leading: IconButton(
            onPressed: () => {
                  ZoomDrawer.of(context)!.toggle(),
                },
            icon: Icon(Icons.menu)),
      ),
      body: Center(
        child: const Text('This is Item 1 Page content'),
      ),
    );
  }
}

class Item2Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text('This is Item 2 Page content'),
      ),
    );
  }
}
// Import your BottomBar file


