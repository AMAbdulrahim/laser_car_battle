import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider<PlayerViewModel>(
      create: (_) => PlayerViewModel(),
    ),
    ChangeNotifierProvider<GameViewModel>(
      create: (_) => GameViewModel(),
    ),
  ];
}
