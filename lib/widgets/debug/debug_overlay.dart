import 'package:flutter/material.dart';
import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';

class DebugOverlay extends StatelessWidget {
  final CarControllerViewModel controller;

  const DebugOverlay({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, 0.3), // Values range from -1 to 1, positive y moves down
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Info',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Joystick: (${controller.xAxis.toStringAsFixed(2)}, ${controller.yAxis.toStringAsFixed(2)})',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Brake: ${controller.isBraking}',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Shots Fired: ${controller.fireCount}',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Last Action: \n${controller.lastAction}',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}