import 'package:concentric_transition/page_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:myschool/BottomBar.dart';
import 'package:myschool/RegisterScreen.dart';
import 'package:myschool/controllers/AuthScreen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class ConcentricTransitionPage extends StatefulWidget {
  const ConcentricTransitionPage({Key? key}) : super(key: key);

  @override
  State<ConcentricTransitionPage> createState() =>
      _ConcentricTransitionPageState();
}

class _ConcentricTransitionPageState extends State<ConcentricTransitionPage> {
  List<ConcentricModel> concentrics = [
    ConcentricModel(
      lottie:
          'https://lottie.host/48a2a900-50ea-41d5-ad8a-12860e192604/A18Q8PcQ0e.json',
      text: "Get new\nknowledge",
    ),
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

  // SharedPreferences instance for persistent storage
  late SharedPreferences _prefs;
  bool _showIntro = true; // Flag to determine if intro should be shown
  bool _isLoggedIn = false; // Flag to determine if user is logged in

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _checkAuthStatus();
  }

  // Initialize SharedPreferences
  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _showIntro =
        _prefs.getBool('show_intro') ?? true; // Check if show_intro is set
    setState(() {}); // Update the state to reflect changes
  }

  // Check authentication status using AuthController
  Future<void> _checkAuthStatus() async {
    AuthController authController = AuthController();
    _isLoggedIn = await authController.isUserAuthenticated();
    setState(() {}); // Update the state to reflect changes
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      // If logged in, navigate to main content
      return BottomBar();
    } else {
      // Otherwise, show intro screen
      return _showIntro ? _buildIntroScreen() : BuyerRegisterScreen();
    }
  }

  Widget _buildIntroScreen() {
    return SafeArea(
      child: Scaffold(
        body: ConcentricPageView(
          // Your existing ConcentricPageView setup
          onChange: (val) {},
          colors: const <Color>[
            Color.fromARGB(255, 249, 153, 198),
            Color(0xff013BCA),
            Colors.white,
            Color.fromARGB(183, 244, 114, 240),
          ],
          itemCount: concentrics.length,
          onFinish: () {
            _prefs.setBool(
                'show_intro', false); // Set show_intro to false once finished
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BuyerRegisterScreen()),
            );
          },
          itemBuilder: (int index) {
            return Column(
              children: [
                // Your existing widget structure
                // Ensure to replace with your existing UI code
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, right: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuyerRegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          color: index == 2 ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 25,
                        ),
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
                      fontSize: 22,
                    ),
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

  ConcentricModel({
    required this.lottie,
    required this.text,
  });
}
