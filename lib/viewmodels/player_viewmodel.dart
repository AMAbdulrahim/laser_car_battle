import 'package:flutter/material.dart';

class PlayerViewModel extends ChangeNotifier {
  String _playerName = '';

  String get playerName => _playerName;

  void setPlayerName(String name) {
    _playerName = name;
    notifyListeners();
  }
}
