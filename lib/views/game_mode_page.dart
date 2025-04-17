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
  bool isDebugMode = false; // Default debug mode to false

  @override
  void initState() {
    super.initState();
    
    // Listen for mode changes and load games when switching to join mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isHost) {
        // Use the ViewModel's method instead
        context.read<GameViewModel>().loadWaitingGames();
      }
      
      // Initialize debug state from GameViewModel
      setState(() {
        isDebugMode = context.read<GameViewModel>().debugBypassActiveCheck;
      });
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

  void _onDebugModeChanged(bool enabled) {
    final gameViewModel = context.read<GameViewModel>();
    gameViewModel.setDebugBypassActiveCheck(enabled);
    setState(() {
      isDebugMode = enabled;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Debug mode ${enabled ? 'enabled' : 'disabled'}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: enabled ? Colors.orange : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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
              // Debug mode toggle
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Debug Mode",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: isDebugMode,
                          onChanged: _onDebugModeChanged,
                          activeColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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