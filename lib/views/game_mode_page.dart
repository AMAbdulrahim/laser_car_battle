import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:laser_car_battle/widgets/buttons/action_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class GameModePage extends StatefulWidget {
  const GameModePage({super.key});

  @override
  State<GameModePage> createState() => _GameModePageState();
}

class _GameModePageState extends State<GameModePage> {
  String? selectedMode;
  int? timePickerValue = 3;
  int? pointPickerValue = 2;
  bool isHost = true; // Default to host/create mode

  Widget _buildToggleButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingLarge),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CustomColors.background,
        borderRadius: BorderRadius.circular(AppSizes.borderLarge),
        border: Border.all(color: CustomColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            text: 'Create Game',
            isSelected: isHost,
            onTap: () => setState(() => isHost = true),
          ),
          _buildToggleOption(
            text: 'Join Game',
            isSelected: !isHost,
            onTap: () => setState(() => isHost = false),
          ),
        ],
      ),
    );
  }

  final TextEditingController _gameCodeController = TextEditingController();

  Widget _buildJoinGameSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: TextField(
            controller: _gameCodeController,
            decoration: InputDecoration(
              labelText: 'Enter Game Code',
              hintText: 'e.g. 1234',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderMedium),
              ),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: AppSizes.fontMedium),
            // Add these properties for numeric keyboard
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            // Optional: Limit to a reasonable length for game codes
            maxLength: 4,
          ),
        ),
        SizedBox(height: AppSizes.paddingLarge),
        ActionButton(
          onPressed: () async {
            if (_gameCodeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a game code')),
              );
              return;
            }
            
            final gameViewModel = context.read<GameViewModel>();
            final playerName = context.read<PlayerViewModel>().playerName;
            
            // Join the game as player2
            final success = await gameViewModel.joinGame(_gameCodeController.text, playerName);
            
            // Add this check before using context after the await
            if (!mounted) return;
            
            if (success) {
              Navigator.pushNamed(context, '/controller');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Game not found or could not join')),
              );
            }
          },
          buttonText: "Join Game",
        ),
      ],
    );
  }

  Widget _buildToggleOption({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected ? CustomColors.mainButton : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.borderMedium),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : CustomColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget _buildJoiningIndicator() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const CircularProgressIndicator(),
  //         const SizedBox(height: AppSizes.paddingLarge),
  //         Text(
  //           'Waiting for host to setup the game...',
  //           style: TextStyle(
  //             color: CustomColors.textPrimary,
  //             fontSize: AppSizes.fontMedium,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: CustomAppBar(
          titleText: "Game Setup",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              _buildToggleButtons(),
              Expanded(
                child: isHost
                    ? SingleChildScrollView(
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
                            // Show different pickers based on selected mode
                          SizedBox(height: AppSizes.paddingLarge),
                            if (selectedMode != null) ...[
                              if (selectedMode == 'Points') ...[
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // Add this for better spacing
                                    children: <Widget>[
                                
                                      // Add NumberPicker for time selection
                                      Container(
                                        // color: CustomColors.border,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(29, 79, 0, 0),
                                          border: Border.all(color: CustomColors.border,width: 5, ),
                                          borderRadius: BorderRadius.circular(AppSizes.borderLarge,),
                                        ),
                                        padding: const EdgeInsets.all(AppSizes.paddingLarge),
                                        child: NumberPicker(
                                          
                                          axis: Axis.horizontal ,
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
                                          itemHeight: 80, // Makes the picker taller
                                          itemWidth: 80,  // Makes the picker wider
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
                                )
                               
                              ] else if (selectedMode == 'Time') ...[
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // Add this for better spacing
                                    children: <Widget>[
                                
                                      // Add NumberPicker for time selection
                                      Container(
                                        // color: CustomColors.border,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(29, 79, 0, 0),
                                          border: Border.all(color: CustomColors.border, width: 5),
                                          borderRadius: BorderRadius.circular(AppSizes.borderLarge),
                                        ),
                                        padding: const EdgeInsets.all(AppSizes.paddingLarge),
                                        child: NumberPicker(
                                          // axis: Axis.horizontal ,
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
                                          itemHeight: 80, // Makes the picker taller
                                          itemWidth: 80,  // Makes the picker wider
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
                                )
                              ],
                              SizedBox(height: AppSizes.paddingLarge),
                              ActionButton(
                                onPressed: () {
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
                                },
                                buttonText: "Create Game",
                              ),
                            ],
                          ],
                        ),
                      )
                    : _buildJoinGameSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}