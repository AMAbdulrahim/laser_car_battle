import 'package:flutter/material.dart';
import 'package:laser_car_battle/services/bluetooth_service.dart';
import 'package:laser_car_battle/viewmodels/bluetooth_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/leaderboard_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<SingleChildWidget> getProviders(GlobalKey<NavigatorState> navigatorKey) {
  final supabaseClient = Supabase.instance.client;
  final bluetoothService = BluetoothService();

  return [
    ChangeNotifierProvider<BluetoothViewModel>(
      create: (_) => BluetoothViewModel(bluetoothService),
    ),
    ChangeNotifierProvider<LeaderboardViewModel>(
      create: (_) => LeaderboardViewModel(supabaseClient),
    ),
    ChangeNotifierProvider<GameViewModel>(
      create: (context) => GameViewModel(
        bluetoothService,
        navigatorKey,
        Provider.of<LeaderboardViewModel>(context, listen: false),
        supabaseClient,
      ),
    ),
    ChangeNotifierProvider<PlayerViewModel>(
      create: (context) => PlayerViewModel(
        gameViewModel: Provider.of<GameViewModel>(context, listen: false),
        playerNumber: 1, // This can also be dynamic if needed
      ),
    ),

    // ✅ Dynamically assign correct player controller (only one controller is created)
    ChangeNotifierProxyProvider<GameViewModel, CarControllerViewModel>(
      create: (context) => CarControllerViewModel(
        gameViewModel: Provider.of<GameViewModel>(context, listen: false),
        playerNumber: 1, // temporary, will be overridden
      ),
      update: (context, gameViewModel, _) {
        return CarControllerViewModel(
          gameViewModel: gameViewModel,
          playerNumber: gameViewModel.isHost ? 1 : 2,
        );
      },
    ),
  ];
}
