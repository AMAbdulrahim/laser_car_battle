import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:laser_car_battle/models/leaderboard_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final SupabaseClient _supabase;
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isConnected = false;

  // Store original entries to reset filters
  List<LeaderboardEntry> _originalEntries = [];

  // Flag to track if filter has been applied
  bool _isFiltered = false;

  LeaderboardViewModel(this._supabase) {
    _checkConnectivity();
    _setupConnectivityStream();
  }

  List<LeaderboardEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isConnected => _isConnected;

  Future<void> _checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }

  void _setupConnectivityStream() {
    Connectivity().onConnectivityChanged.listen((result) {
      _isConnected = result != ConnectivityResult.none;
      notifyListeners();
      if (_isConnected) {
        loadLeaderboard();
      }
    });
  }

  Future<void> loadLeaderboard() async {
    if (!_isConnected) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await _supabase
          .from('leaderboard')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      _entries = (response as List)
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList();
      
      // Store original order
      _originalEntries = List.from(_entries);
      _isFiltered = false;
    } catch (e) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(LeaderboardEntry entry) async {
    try {
      await _supabase.from('leaderboard').insert({
        'winner': entry.winner,
        'loser': entry.loser,
        'winner_score': entry.winnerScore,
        'loser_score': entry.loserScore,
        'game_mode': entry.gameMode,
        'game_value': entry.gameValue,
        'duration': entry.duration,
        'created_at': entry.timestamp.toIso8601String(),
      });
      
      // Refresh leaderboard after adding entry
      await loadLeaderboard();
    } catch (e) {
      print('Error adding leaderboard entry: $e');
      throw e;
    }
  }

  void filterByRecent() {
    // First ensure we're working with all entries if previously reset
    if (_isFiltered) {
      _entries = List.from(_originalEntries);
    }
    
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _isFiltered = true;
    notifyListeners();
  }

  void filterByHighestScore() {
    // First ensure we're working with all entries if previously reset
    if (_isFiltered) {
      _entries = List.from(_originalEntries);
    }
    
    _entries.sort((a, b) => b.winnerScore.compareTo(a.winnerScore));
    _isFiltered = true;
    notifyListeners();
  }

  void filterByLowestScore() {
    // First ensure we're working with all entries if previously reset
    if (_isFiltered) {
      _entries = List.from(_originalEntries);
    }
    
    _entries.sort((a, b) => a.winnerScore.compareTo(b.winnerScore));
    _isFiltered = true;
    notifyListeners();
  }

  void resetFilters() {
    _entries = List.from(_originalEntries);
    _isFiltered = false;
    notifyListeners();
  }

  // Add this method to your LeaderboardViewModel class
  void filterByGameMode(String gameMode) {
    if (gameMode == 'All') {
      _entries = List.from(_originalEntries);
    } else {
      _entries = _originalEntries
          .where((entry) => entry.gameMode == gameMode)
          .toList();
    }
    
    // Re-apply current sort based on the last selected sort option
    // You'll need to track this in the ViewModel or pass it from the UI
    notifyListeners();
  }
}