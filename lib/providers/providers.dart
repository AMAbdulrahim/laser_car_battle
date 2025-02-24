import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';

List<ChangeNotifierProvider> getProviders() {
  return [
    ChangeNotifierProvider<GameViewModel>(
      create: (_) => GameViewModel(),
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
