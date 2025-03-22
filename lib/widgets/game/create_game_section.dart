import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:laser_car_battle/widgets/buttons/action_button.dart';

class CreateGameSection extends StatefulWidget {
  const CreateGameSection({super.key});

  @override
  State<CreateGameSection> createState() => _CreateGameSectionState();
}

class _CreateGameSectionState extends State<CreateGameSection> {
  String? selectedMode;
  int? timePickerValue = 3;
  int? pointPickerValue = 2;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DropdownButtonFormField2<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Select Game Mode',
            ),
            items: <String>['Points', 'Time']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedMode = value;
              });
            },
          ),
          SizedBox(height: AppSizes.paddingLarge),
          if (selectedMode != null) ...[
            if (selectedMode == 'Points')
              _buildPointsSelector()
            else if (selectedMode == 'Time')
              _buildTimeSelector(),
            SizedBox(height: AppSizes.paddingLarge),
            ActionButton(
              onPressed: () => _createGame(context),
              buttonText: "Create Game",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPointsSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(29, 79, 0, 0),
              border: Border.all(color: CustomColors.border, width: 5),
              borderRadius: BorderRadius.circular(AppSizes.borderLarge),
            ),
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: NumberPicker(
              axis: Axis.horizontal,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CustomColors.border, width: 3),
              ),
              value: pointPickerValue!,
              minValue: 1,
              maxValue: 15,
              step: 1,
              haptics: true,
              textStyle: const TextStyle(
                fontSize: 40,
                color: CustomColors.buttonText,
              ),
              selectedTextStyle: const TextStyle(
                fontSize: 50,
                color: CustomColors.textPrimary,
              ),
              itemHeight: 80,
              itemWidth: 80,
              onChanged: (value) {
                setState(() {
                  pointPickerValue = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Text(
              'Win by $pointPickerValue point(s)',
              style: const TextStyle(fontSize: AppSizes.fontMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(29, 79, 0, 0),
              border: Border.all(color: CustomColors.border, width: 5),
              borderRadius: BorderRadius.circular(AppSizes.borderLarge),
            ),
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: NumberPicker(
              decoration: BoxDecoration(
                border: Border.all(color: CustomColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              value: timePickerValue!,
              minValue: 1,
              maxValue: 15,
              step: 1,
              haptics: true,
              textStyle: const TextStyle(
                fontSize: 40,
                color: CustomColors.buttonText,
              ),
              selectedTextStyle: const TextStyle(
                fontSize: 50,
                color: CustomColors.textPrimary,
              ),
              itemHeight: 80,
              itemWidth: 80,
              onChanged: (value) {
                setState(() {
                  timePickerValue = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Text(
              'Time: $timePickerValue minutes',
              style: const TextStyle(fontSize: AppSizes.fontMedium),
            ),
          ),
        ],
      ),
    );
  }

  void _createGame(BuildContext context) {
    if (selectedMode == null || 
        (selectedMode == 'Time' && timePickerValue == null) || 
        (selectedMode == 'Points' && pointPickerValue == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a game mode and value')),
      );
      return;
    }
    
    final gameViewModel = context.read<GameViewModel>();
    final playerName = context.read<PlayerViewModel>().playerName;
    
    // Set as host
    gameViewModel.setIsHost(true);
    
    // Set game settings
    gameViewModel.setGameSettings(
      selectedMode!, 
      selectedMode == 'Time' ? timePickerValue! : pointPickerValue!
    );
    
    // Assign name as player1 (host)
    gameViewModel.player1Name = playerName;
    
    Navigator.pushNamed(context, '/controller');
  }
}