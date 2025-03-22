import 'package:flutter/material.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/widgets/game/create_game_section.dart';
import 'package:laser_car_battle/widgets/game/join_game_section.dart';
import 'package:laser_car_battle/widgets/game/mode_toggle_buttons.dart';

class GameModePage extends StatefulWidget {
  const GameModePage({super.key});

  @override
  State<GameModePage> createState() => _GameModePageState();
}

class _GameModePageState extends State<GameModePage> {
  bool isHost = true; // Default to host/create mode

  @override
  void initState() {
    super.initState();
    
    // Listen for mode changes and load games when switching to join mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isHost) {
        // Use the ViewModel's method instead
        context.read<GameViewModel>().loadWaitingGames();
      }
    });
  }

  void _onModeChanged(bool hostMode) {
    setState(() {
      isHost = hostMode;
    });
    
    if (!hostMode) {
      // Load waiting games when switching to join mode
      context.read<GameViewModel>().loadWaitingGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: CustomAppBar(
          titleText: "Game Setup",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              ModeToggleButtons(
                isHost: isHost,
                onModeChanged: _onModeChanged,
              ),
              Expanded(
                child: isHost
                    ? const CreateGameSection()
                    : const JoinGameSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}