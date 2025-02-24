import 'package:flutter/material.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';

class PlayerViewModel extends ChangeNotifier {
  final GameViewModel gameViewModel;
  final int playerNumber;
  String _playerName = '';

  PlayerViewModel({
    required this.gameViewModel,
    required this.playerNumber,
  });

  String get playerName => _playerName;

  void setPlayerName(String name) {
    _playerName = name;
    if (playerNumber == 1) {
      gameViewModel.player1Name = name;
    } else {
      gameViewModel.player2Name = name;
    }
    notifyListeners();
  }
}
