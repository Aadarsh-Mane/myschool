import 'package:flutter/material.dart';
import 'package:myschool/RegisterScreen.dart';
import 'package:myschool/Snack.dart';
import 'package:myschool/controllers/AuthScreen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/quickalert.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class LogoutScreen extends StatelessWidget {
  final AuthController _authController = AuthController();

  void _showLogoutDialog(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'Do you want to logout?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () {
        _logoutUser(context); // Call logout function if user confirms
      },
    );
  }

  void _logoutUser(BuildContext context) async {
    await _authController.signOutUser();
    showSnack(context, 'You have been logged out.');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BuyerRegisterScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(context), // Show QuickAlert dialog
          child: Text('Logout'),
        ),
      ),
    );
  }
}
