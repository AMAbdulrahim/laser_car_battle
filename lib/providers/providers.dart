import 'package:flutter/material.dart';
import 'package:laser_car_battle/services/bluetooth_service.dart';
import 'package:laser_car_battle/viewmodels/bluetooth_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/leaderboard_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<ChangeNotifierProvider> getProviders(GlobalKey<NavigatorState> navigatorKey) {
  final supabaseClient = Supabase.instance.client;
  final bluetoothService = BluetoothService();
  
  return [
    ChangeNotifierProvider<BluetoothViewModel>(
      create: (_) => BluetoothViewModel(),
    ),
    ChangeNotifierProvider<LeaderboardViewModel>(
      create: (_) => LeaderboardViewModel(supabaseClient),
    ),
    ChangeNotifierProvider<GameViewModel>(
      create: (context) => GameViewModel(
        bluetoothService,
        navigatorKey,
        Provider.of<LeaderboardViewModel>(context, listen: false),
      ),
    ),
    ChangeNotifierProvider<PlayerViewModel>(
      create: (context) => PlayerViewModel(
        gameViewModel: Provider.of<GameViewModel>(context, listen: false),
        playerNumber: 1,
      ),
    ),
    // Controller for Player 1
    ChangeNotifierProvider<CarControllerViewModel>(
      create: (context) => CarControllerViewModel(
        gameViewModel: Provider.of<GameViewModel>(context, listen: false),
        playerNumber: 1,
      ),
    ),
    // Controller for Player 2
    ChangeNotifierProvider<CarControllerViewModel>(
      create: (context) => CarControllerViewModel(
        gameViewModel: Provider.of<GameViewModel>(context, listen: false),
        playerNumber: 2,
      ),
    ),
  ];
}
