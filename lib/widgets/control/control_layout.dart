import 'package:flutter/material.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:laser_car_battle/widgets/buttons/brake_button.dart';
import 'package:laser_car_battle/widgets/buttons/fire_button.dart';
import 'package:laser_car_battle/widgets/control/arrow_control.dart';
import 'package:laser_car_battle/widgets/control/custom_joystick.dart';
import 'package:laser_car_battle/widgets/control/speed_slider.dart';

class ControlLayout extends StatelessWidget {
  final bool controlsOnLeft;
  final bool useJoystick;
  final double maxSpeed;
  final bool holdSteering;
  final CarControllerViewModel controller;
  final Function(double) onSpeedChanged;
  final Function(bool) onToggleHoldSteering;

  const ControlLayout({
    super.key,
    required this.controlsOnLeft,
    required this.useJoystick,
    required this.maxSpeed,
    required this.holdSteering,
    required this.controller,
    required this.onSpeedChanged,
    required this.onToggleHoldSteering,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Control buttons (fire and brake/speed slider)
        Positioned(
          bottom: AppSizes.paddingXLarge,
          left: controlsOnLeft ? AppSizes.paddingXLarge : null,
          right: controlsOnLeft ? null : AppSizes.paddingXLarge,
          child: _buildControlButtons(),
        ),
        
        // Joystick or arrow controls
        Positioned(
          bottom: AppSizes.paddingXLarge,
          left: controlsOnLeft ? null : AppSizes.paddingXLarge + 20,
          right: controlsOnLeft ? AppSizes.paddingXLarge + 20 : null,
          child: _buildDirectionalControl(),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: controlsOnLeft
          ? [
              useJoystick
                  ? BrakeButton(
                      onPressed: () => controller.setBrakeState(true),
                      onReleased: () => controller.setBrakeState(false),
                      width: 100,
                      height: 150,
                      isRightBrake: false,
                    )
                  : SpeedSlider(
                      value: maxSpeed,
                      onChanged: onSpeedChanged,
                      width: 80,
                      height: 180,
                      isRightSide: false,
                    ),
              Padding(
                padding: const EdgeInsets.only(left: AppSizes.paddingLarge),
                child: FireButton(
                  onPressed: () => controller.fire(),
                  size: 150,
                ),
              ),
            ]
          : [
              FireButton(
                onPressed: () => controller.fire(),
                size: 150,
              ),
              Padding(
                padding: const EdgeInsets.only(left: AppSizes.paddingLarge),
                child: useJoystick
                    ? BrakeButton(
                        onPressed: () => controller.setBrakeState(true),
                        onReleased: () => controller.setBrakeState(false),
                        width: 100,
                        height: 150,
                        isRightBrake: true,
                      )
                    : SpeedSlider(
                        value: maxSpeed,
                        onChanged: onSpeedChanged,
                        width: 80,
                        height: 180,
                        isRightSide: true,
                      ),
              ),
            ],
    );
  }

  Widget _buildDirectionalControl() {
    return useJoystick
        ? CustomJoystick(
            listener: controller.updateJoystickPosition,
          )
        : ArrowControls(
            onControlUpdate: controller.updateJoystickPosition,
            onBrakePressed: controller.setBrakeState,
            maxSpeed: maxSpeed,
            holdSteering: holdSteering,
            controlsOnLeft: controlsOnLeft,
            onToggleHoldSteering: onToggleHoldSteering,
          );
  }
}