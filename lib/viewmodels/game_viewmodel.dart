import 'package:flutter/material.dart';

class GameViewModel extends ChangeNotifier {
  String? _gameMode;
  int? _gameValue;

  String? get gameMode => _gameMode;
  int? get gameValue => _gameValue;

  void setGameSettings(String mode, int value) {
    _gameMode = mode;
    _gameValue = value;
    notifyListeners();
  }

  void clearGameSettings() {
    _gameMode = null;
    _gameValue = null;
    notifyListeners();
  }
}
