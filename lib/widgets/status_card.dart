import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.checkStatus,
    required this.statusText,
  });

  final bool checkStatus;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(
      color: CustomColors.backgroundEffect,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3), // changes position of shadow
      ),
      ],
    ),
    height: 155,
    width: double.infinity,
    
    padding: const EdgeInsets.all(AppSizes.paddingMedium),
    child: Column(
      children: [
      Text(
        statusText,
        style: const TextStyle(
        fontSize: AppSizes.fontMain,
        ),
      ),
      const SizedBox(height: 20),
      if (checkStatus)
      
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 60,
          child: const Text(
            "Connected",
            style: TextStyle(
            fontSize: AppSizes.fontMedium,
            ),
          ),
        )
        else
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(CustomColors.textPrimary),
        ),
        
      ],
    ),
    );
  }
}