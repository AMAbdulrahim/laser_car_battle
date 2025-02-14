import 'package:flutter/material.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/widgets/buttons/action_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:laser_car_battle/widgets/status_card.dart';

class BTConnectionPage extends StatelessWidget {
  final bool isConnectedOpponent = true;	
  final bool isConnectedPlayer = true;	


  const BTConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: AppSizes.paddingLarge * 2),

                Container(
                  height: AppSizes.paddingLarge * 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // color: Colors.grey[300],
                    //borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text("Hi AliXXXXXXXXXXXX,", style: TextStyle(fontSize: AppSizes.fontMain),),
                ),

                StatusCard(
                  checkStatus: isConnectedPlayer,
                  statusText: "Connect via Bluetooth", 
                ),
                
                SizedBox(height:AppSizes.paddingLarge),

                StatusCard(
                  checkStatus: isConnectedOpponent,
                  statusText: "Opponent", 
                ),

                SizedBox(height:AppSizes.paddingLarge * 1.5),


                if (isConnectedOpponent && true && isConnectedPlayer) ...[
                    ActionButton(
                      onPressed: () {

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
