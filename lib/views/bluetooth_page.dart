import 'package:flutter/material.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:laser_car_battle/widgets/buttons/action_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:laser_car_battle/widgets/status_card.dart';
import 'package:provider/provider.dart';

class BTConnectionPage extends StatelessWidget {
  final bool isConnectedOpponent = true;	
  final bool isConnectedPlayer = true;	

  const BTConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {

    final playerName = context.watch<PlayerViewModel>().playerName;
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: CustomAppBar(
          titleText: "Connect",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              
              Container(
                height: AppSizes.paddingLarge * 4,
                width: double.infinity,
                decoration: BoxDecoration(),
                child: Text(
                  "Hi, $playerName",
                  style: const TextStyle(
                    fontSize: AppSizes.fontMain,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
              StatusCard(
                checkStatus: isConnectedPlayer,
                statusText: "Connect via Bluetooth", 
              ),
              SizedBox(height: AppSizes.paddingLarge),
              StatusCard(
                checkStatus: isConnectedOpponent,
                statusText: "Opponent", 
              ),
              SizedBox(height: AppSizes.paddingLarge * 1.5),
              if (isConnectedOpponent && true && isConnectedPlayer) ...[
                ActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/gameMode');
                  },
                  buttonText: "Game Mode", 
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
