import 'package:flutter/material.dart';

class LoginViewModel with ChangeNotifier {
  String _userName = '';

  String get userName => _userName;

  void setUserName(String userName) {
    _userName = userName;
    notifyListeners();
  }
  void clearUserName() {
    _userName = '';
    notifyListeners();
  }

 String getUserName() {
    return _userName;
  }
}
