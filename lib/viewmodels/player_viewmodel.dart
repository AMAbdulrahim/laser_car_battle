import 'package:flutter/material.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';

/// PlayerViewModel handles the state and logic for individual players
/// This class follows the MVVM pattern to separate player-specific logic from the UI
class PlayerViewModel extends ChangeNotifier {
  // GameViewModel is injected to maintain connection with the main game state
  // This allows for centralized game state management
  final GameViewModel gameViewModel;
  
  // playerNumber is used to identify which player (1 or 2) this viewmodel represents
  // This enables reuse of the same viewmodel class for both players
  final int playerNumber;
  
  // Private field for encapsulation, preventing direct external modification
  // This follows the principle of data hiding
  String _playerName = '';

  /// Constructor requires gameViewModel and playerNumber to ensure proper initialization
  /// This enforces that essential dependencies are provided at creation time
  PlayerViewModel({
    required this.gameViewModel,
    required this.playerNumber,
  });

  /// Getter for playerName provides read-only access to the private field
  /// This maintains encapsulation while allowing access to the data
  String get playerName => _playerName;

  /// Updates the player name and syncs it with the main game state
  /// Notifies listeners to ensure UI updates when the name changes
  /// @param name The new name to set for the player
  void setPlayerName(String name) {
    _playerName = name;
    // Updates the corresponding player name in the game viewmodel
    // This ensures consistency between local and global state
    if (playerNumber == 1) {
      gameViewModel.player1Name = name;
    } else {
      gameViewModel.player2Name = name;
    }
    // Notifies listeners (usually UI elements) about the state change
    // This triggers a rebuild of dependent widgets
    notifyListeners();
  }
}
