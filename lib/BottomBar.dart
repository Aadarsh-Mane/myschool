import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:myschool/RegisterScreen.dart';
import 'package:myschool/Snack.dart';
import 'package:myschool/controllers/AuthScreen.dart';
import 'package:myschool/main.dart';
import 'package:myschool/pages/shared/my_page_button.dart';
import 'package:myschool/user/HomePage.dart';
import 'package:myschool/user/YoutubeWatchScreen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/quickalert.dart';

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

class SettingsScreen extends StatelessWidget {
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
                    image: AssetImage(
                      'assets/images/head.jpeg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Person's Name and Position
              Text(
                'Director', // Replace with the actual position
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: const Color.fromARGB(255, 166, 57, 57),
                ),
              ),
              Text(
                'Smt.  Sulbha Uttam Kamble', // Replace with the actual name
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
              _buildInfoItem('Location', 'Lodha Heaven,Dombivli'),
              _buildInfoItem('Founded', '2000'),
              _buildInfoItem('Accreditation', 'Accredited'),
              SizedBox(height: 16),
              // Head of School
              // _buildSectionTitle('Principal'),
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
              // Additional Information Card
              _buildAdditionalInformationCard(),
              SizedBox(height: 20),
              // Add a Button for showing the dialog
              ElevatedButton(
                onPressed: () {
                  _showLoginDialog(context);
                },
                child: Text('Admin Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

  Widget _buildAdditionalInformationCard() {
    return Card(
      color: Color(0xFFF5EEE6),
      elevation: 15,
      margin: EdgeInsets.all(48),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Vestibulum euismod ex quis malesuada pretium.',
              style: TextStyle(fontSize: 14),
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
              padding: EdgeInsets.all(20),
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
                    'Admin Login',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: 'Enter ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Enter Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     if (idController.text == '123' &&
                  //         passwordController.text == 'abc') {
                  //       Navigator.of(context).pop();
                  //       Navigator.of(context).push(
                  //         // MaterialPageRoute(
                  //         //     builder: (context) => const ButtonPage()),
                  //       // );
                  //       )
                  //     } else {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(
                  //           content: Text('Invalid ID or Password'),
                  //         ),
                  //       );
                  //     }
                  //   },
                  //   child: Text('Login'),
                  // ),
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
