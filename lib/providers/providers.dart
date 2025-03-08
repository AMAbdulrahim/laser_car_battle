import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/leaderboard_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<ChangeNotifierProvider> getProviders() {
  // Access the already initialized Supabase instance
  final supabaseClient = Supabase.instance.client;
  
  return [
    ChangeNotifierProvider<LeaderboardViewModel>(
      create: (_) => LeaderboardViewModel(supabaseClient),
    ),
    ChangeNotifierProvider<GameViewModel>(
      create: (context) => GameViewModel(
        Provider.of<LeaderboardViewModel>(context, listen: false),
      ),
    ),
    ChangeNotifierProvider<PlayerViewModel>(
      create: (context) => PlayerViewModel(
        gameViewModel: Provider.of<GameViewModel>(context, listen: false),
        playerNumber: 1,
      ),
    ),
    ChangeNotifierProvider<CarControllerViewModel>(
      create: (context) => CarControllerViewModel(
        gameViewModel: Provider.of<GameViewModel>(context, listen: false),
      ),
    ),
  ];
}
