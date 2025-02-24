import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/widgets/buttons/action_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:provider/provider.dart';

class GameModePage extends StatefulWidget {
  const GameModePage({super.key});

  @override
  State<GameModePage> createState() => _GameModePageState();
}

class _GameModePageState extends State<GameModePage> {
  String? selectedMode;
  int? timePickerValue = 3;
  int? pointPickerValue = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: CustomAppBar(
          titleText: "Game Mode",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: AppSizes.paddingLarge * 4),
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
            
            // Show different pickers based on selected mode
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
              // Only show action button when mode is selected
              ActionButton(
                onPressed: () {
                  if (selectedMode == 'Points') {
                    context.read<GameViewModel>().setGameSettings('Points', pointPickerValue!);
                  } else if (selectedMode == 'Time') {
                    context.read<GameViewModel>().setGameSettings('Time', timePickerValue!);
                  }
                  Navigator.pushNamed(context, 'controller');
                }, 
                buttonText: "Start Game"
              ),
            ],
          ],
        ),
      ),
    );
  }
}