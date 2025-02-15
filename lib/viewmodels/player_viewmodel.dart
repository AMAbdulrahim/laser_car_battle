import 'package:flutter/material.dart';

class LoginViewModel with ChangeNotifier {
  String _playerName = '';

  String get playerName => _playerName;

  void setplayerName(String playerName) {
    _playerName = playerName;
    notifyListeners();
  }
  void clearplayerName() {
    _playerName = '';
    notifyListeners();
  }

 String getplayerName() {
    return _playerName;
  }
}
