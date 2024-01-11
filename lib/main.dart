import 'dart:developer';

import 'package:concentric_transition/concentric_transition.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:myschool/AddData.dart';
import 'package:myschool/pages/home_page.dart';
import 'package:myschool/pages/my_page_button.dart';
import 'package:myschool/user/HomePage.dart';

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
      home: const SideBar(),
      // home: const ConcentricTransitionPage(),
    );
  }
}

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      menuScreen: MenuScreen(),
      mainScreen: MainScreen(),
      borderRadius: 24.0,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => ZoomDrawer.of(context)!.toggle()),
      ),
      body: UserHomePage(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 231, 140, 211),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text(
                'Item 1',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Item1Page()), // Navigate to Item1Page
                );
              },
            ),
            ListTile(
              title: const Text(
                'Item 2',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Item2Page()), // Navigate to Item2Page
                );
              },
            ),
            // Add more ListTiles for additional menu items
          ],
        ),
      ),
    );
  }
}

class Item1Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item 1 Page'),
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

class ConcentricTransitionPage extends StatefulWidget {
  const ConcentricTransitionPage({Key? key}) : super(key: key);

  @override
  State<ConcentricTransitionPage> createState() =>
      _ConcentricTransitionPageState();
}

class _ConcentricTransitionPageState extends State<ConcentricTransitionPage> {
/////////////////////////////////////
//@CodeWithFlexz on Instagram
//
//AmirBayat0 on Github
//Programming with Flexz on Youtube
/////////////////////////////////////
  List<ConcentricModel> concentrics = [
    ConcentricModel(
      lottie: "https://assets4.lottiefiles.com/packages/lf20_lhpm8hja.json",
      text: "Get new\nknowledge",
    ),
    ConcentricModel(
      lottie: "https://assets6.lottiefiles.com/packages/lf20_tk6xxpgj.json",
      text: "Take time for\nyourself",
    ),
    ConcentricModel(
      lottie: "https://assets8.lottiefiles.com/packages/lf20_fbzszqak.json",
      text: "Do what you\nlove",
    ),
    ConcentricModel(
      lottie: "https://assets8.lottiefiles.com/packages/lf20_prsoqox5.json",
      text: "Try something\nnew",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ConcentricPageView(
          onChange: (val) {},
          colors: const <Color>[
            Color.fromARGB(255, 249, 153, 198),
            Color(0xff013BCA),
            Colors.white,
            Color.fromARGB(183, 244, 114, 240),
          ],
          itemCount: concentrics.length,
          onFinish: () {
            print("Finished");
          },
          itemBuilder: (int index) {
            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, right: 20),
                    child: GestureDetector(
                      onTap: () {
                        print("Skipped");
                      },
                      child: Text(
                        "Skip",
                        style: TextStyle(
                            color: index == 2 ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 25),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 290,
                  width: 300,
                  child:
                      Lottie.network(concentrics[index].lottie, animate: true),
                ),
                Text(
                  concentrics[index].text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    color: index == 2 ? Colors.black : Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    "${index + 1} / ${concentrics.length}",
                    style: GoogleFonts.rubik(
                        color: index == 2 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 22),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ConcentricModel {
  String lottie;
  String text;
  //
  ConcentricModel({
    required this.lottie,
    required this.text,
  });
}
