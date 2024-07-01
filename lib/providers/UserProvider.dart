import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _fullName = '';
  String _imageUrl = '';

  String get fullName => _fullName;
  String get imageUrl => _imageUrl;

  void setUserInfo(String fullName, String imageUrl) {
    _fullName = fullName;
    _imageUrl = imageUrl;
    notifyListeners();
  }
}
