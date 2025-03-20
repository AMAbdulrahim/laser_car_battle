import 'package:flutter/material.dart';

class GameState {
  String? gameMode;
  int? gameValue;
  int timeInSeconds = 0;
  int elapsedSeconds = 0;
  bool isGameActive = false;
  bool isFlashing = false;
  int player1Points = 0;
  int player2Points = 0;
  int? targetPoints;
  String? winner;
  String player1Name = 'Player 1';
  String player2Name = 'Player 2';

  Color get timerColor {
    if (gameMode == 'Time' && gameValue != null) {
      int remainingTime = (gameValue! * 60) - timeInSeconds;
      if (remainingTime <= 30) {
        return isFlashing ? Colors.red : Colors.white;
      }
    }
    return Colors.white;
  }

  String get formattedTime {
    if (gameMode == 'Time') {
      int remainingSeconds = (gameValue! * 60) - timeInSeconds;
      int minutes = remainingSeconds ~/ 60;
      int seconds = remainingSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      int minutes = elapsedSeconds ~/ 60;
      int seconds = elapsedSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void resetPoints() {
    player1Points = 0;
    player2Points = 0;
  }

  void reset() {
    gameMode = null;
    gameValue = null;
    timeInSeconds = 0;
    elapsedSeconds = 0;
    isGameActive = false;
    isFlashing = false;
    player1Points = 0;
    player2Points = 0;
    winner = null;
    player1Name = 'Player 1';
    player2Name = 'Player 2';
  }
}