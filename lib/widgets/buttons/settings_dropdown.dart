import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class SettingsDropdown extends StatelessWidget {
  final VoidCallback onToggleControls;
  final VoidCallback onToggleDebug;

  const SettingsDropdown({
    super.key,
    required this.onToggleControls,
    required this.onToggleDebug,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton2(
      underline: Container(),
      customButton: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(
          Icons.settings_sharp,
          size: AppSizes.iconSize,
          color: CustomColors.textPrimary,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              const Icon(Icons.swap_horiz, color: CustomColors.textPrimary),
              const SizedBox(width: 10),
              Text(
                'Switch Controls',
                style: TextStyle(
                  color: CustomColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'debug',
          child: Row(
            children: [
              const Icon(Icons.bug_report, color: CustomColors.textPrimary),
              const SizedBox(width: 10),
              Text(
                'Toggle Debug',
                style: TextStyle(
                  color: CustomColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'exit',
          child: Row(
            children: [
              const Icon(Icons.exit_to_app, color: CustomColors.textPrimary),
              const SizedBox(width: 10),
              Text(
                'Exit Game',
                style: TextStyle(
                  color: CustomColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        switch (value) {
          case 'toggle':
            onToggleControls();
            break;
          case 'debug':
            onToggleDebug();
            break;
          case 'exit':
            _handleExit(context);
            break;
        }
      },
      dropdownStyleData: DropdownStyleData(
        width: 180,
        offset: const Offset(0, 0),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: CustomColors.mainButton,
        ),
        elevation: 8,
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 40,
        padding: EdgeInsets.only(left: 14, right: 14),
      ),
    );
  }

  void _handleExit(BuildContext context) {
    // Stop game and clean up before exiting
    final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
    final carController = Provider.of<CarControllerViewModel>(context, listen: false);
    
    // Stop any ongoing vibrations
    Vibration.cancel();
    
    // Stop the game timers and state
    gameViewModel.stopGame();
    gameViewModel.clearGameSettings();
    
    // Reset controller state
    carController.setBrakeState(false);
    carController.updateJoystickPosition(0, 0);
    
    // Navigate to landing page
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (Route<dynamic> route) => false,
    );
  }
}