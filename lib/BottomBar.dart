import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:myschool/RegisterScreen.dart';
import 'package:myschool/Snack.dart';
import 'package:myschool/controllers/AuthScreen.dart';
import 'package:myschool/main.dart';
import 'package:myschool/repositories/notfiyapi.dart';
import 'package:myschool/views/pages/my_page_button.dart';
import 'package:myschool/views/user/HomePage.dart';
import 'package:myschool/views/user/YoutubeWatchScreen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;
  final AuthController _authController = AuthController();
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    king();
  }

  king() async {
    await FirebaseApi().initNotification();
  }

  _showLogoutDialog(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'Do you want to logout?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () {
        _logoutUser(context);
        // Close the dialog
        Navigator.of(context).pop();
      },
    );
  }

  _logoutUser(BuildContext context) async {
    await _authController.signOutUser();
    showSnack(context, 'You have been logged out.');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BuyerRegisterScreen()),
      (route) => false,
    );
  }

  _checkAuthentication() async {
    bool isAuthenticated = await _authController.isUserAuthenticated();
    if (!isAuthenticated) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BuyerRegisterScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: CurvedNavigationBar(
        height: 50,
        backgroundColor: Colors.white,
        // color: Color(0xFFF8F4EC),
        // color: Theme.of(context).primaryColor,
        color: Color(0xFFF5EEE6),

        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BottomBar()),
                );
              },
              child: Icon(Icons.home)),
          Icon(Icons.favorite),
          Icon(Icons.info),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return SideBar(); // Replace with your actual home screen widget
      case 1:
        return YoutubeListPage(); // Replace with your actual favorite screen widget
      case 2:
        return SettingsScreen(); // Replace with your actual settings screen widget
      default:
        return Container(); // Handle additional cases if needed
    }
  }
}

// Sample placeholder screens; replace these with your actual screens
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Screen'),
    );
  }
}

class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Favorite Screen'),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      reverseDuration: Duration(seconds: 1),
    )..repeat(reverse: true); // Loop the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EEE6),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // School Photo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage('assets/images/head.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Person's Name and Position
              Text(
                'Director',
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: const Color.fromARGB(255, 166, 57, 57),
                ),
              ),
              Text(
                'Smt. Sulbha Uttam Kamble',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              SizedBox(height: 16),
              // General Information
              _buildInfoItem('School Name', 'The Horizon School'),
              _buildInfoItem('Location', 'Lodha Heaven, Dombivli'),
              _buildInfoItem('Founded', '2000'),
              SizedBox(height: 16),
              // Head of School
              ListTile(
                contentPadding: EdgeInsets.only(top: 10, left: 55),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://cdn.pixabay.com/photo/2023/06/19/05/53/temple-8073501_1280.png',
                  ),
                ),
                title: Text(
                  'Smt Sonali Sakpal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Principal'),
              ),
              SizedBox(height: 35),
              // Location Image and Animated "Click Here" Text
              _buildLocationSection(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        InkWell(
          onTap: _openMap,
          child: Container(
            width: 150,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/location.png'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        FadeTransition(
          opacity: _controller,
          child: Text(
            'Click to get the school location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMap() async {
    const latitude = 19.155000;
    const longitude = 73.078111;
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
