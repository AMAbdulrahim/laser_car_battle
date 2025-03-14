import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/widgets/buttons/fire_button.dart';
import 'package:laser_car_battle/widgets/buttons/brake_button.dart';
import 'package:laser_car_battle/widgets/car_dashboard.dart';
import 'package:laser_car_battle/widgets/custom/custom_joystick.dart';
import 'package:laser_car_battle/widgets/arrow_control.dart';
import 'package:laser_car_battle/widgets/debug_overlay.dart';
import 'package:laser_car_battle/widgets/insights.dart';
import 'package:laser_car_battle/widgets/score_board.dart';
import 'package:laser_car_battle/widgets/speed_slider.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/widgets/buttons/settings_dropdown.dart';
import 'package:laser_car_battle/widgets/car_direction_arrow.dart';

class RemoteController extends StatefulWidget {
  const RemoteController({super.key});

  @override
  State<RemoteController> createState() => _RemoteControllerState();
}

class _RemoteControllerState extends State<RemoteController> {
  bool _controlsOnLeft = true;
  bool _showDebugOverlay = false;
  bool _useJoystick = true;
  bool _useVisualIndicator = false; // New toggle for visual indicator
  double _maxSpeed = 1.0;
  bool _holdSteering = false;  // Default to auto-centering
  late final GameViewModel _gameViewModel;

  void _handleSpeedChange(double value) {
    setState(() => _maxSpeed = value);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameViewModel = Provider.of<GameViewModel>(context, listen: false);

      _gameViewModel.onGameOver = () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/game-over',
            (Route<dynamic> route) => false,
          );
        }
      };

      _gameViewModel.startGame();
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _gameViewModel.stopGame();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CarControllerViewModel>(
      builder: (context, controller, child) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: AppSizes.paddingLarge,
                left: AppSizes.paddingMedium,
                child: SettingsDropdown(
                  onToggleControls: () {
                    setState(() {
                      _controlsOnLeft = !_controlsOnLeft;
                    });
                  },
                  onToggleDebug: () {
                    setState(() {
                      _showDebugOverlay = !_showDebugOverlay;
                    });
                  },
                  onToggleControlType: () {
                    setState(() {
                      _useJoystick = !_useJoystick;
                    });
                  },
                  onToggleVisualMode: () {  // Add this function to SettingsDropdown
                    setState(() {
                      _useVisualIndicator = !_useVisualIndicator;
                    });
                  },
                ),
              ),
              Positioned(
                top: AppSizes.paddingLarge,
                right: AppSizes.paddingMedium,
                child: Insights(),
              ),
              Positioned(
                top: AppSizes.paddingLarge,
                left: 0,
                right: 0,
                child: ScoreBoard(),
              ),
              Positioned(
                  top: 180,
                  left: 0,
                  right: 0,
                  child: Center(
                      child: _useVisualIndicator
                        ? CarDirectionArrow(
                            speed: controller.yAxis,
                            angle: controller.xAxis,
                          )
                        : CarDashboard(
                            speed: controller.yAxis,
                            angle: controller.xAxis,
                            maxSpeed: _maxSpeed,
                          )
                  )),
              Positioned(
                bottom: AppSizes.paddingXLarge,
                left: _controlsOnLeft ? AppSizes.paddingXLarge : null,
                right: _controlsOnLeft ? null : AppSizes.paddingXLarge,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _controlsOnLeft
                      ? [
                          _useJoystick
                              ? BrakeButton(
                                  onPressed: () =>
                                      controller.setBrakeState(true),
                                  onReleased: () =>
                                      controller.setBrakeState(false),
                                  width: 100,
                                  height: 150,
                                  isRightBrake: false,
                                )
                              : SpeedSlider(
                                  value: _maxSpeed,
                                  onChanged: (value) {
                                    _handleSpeedChange(value);
                                  },
                                  width: 80,
                                  height: 180,
                                  isRightSide: false,
                                ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: AppSizes.paddingLarge),
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
                            padding:
                                EdgeInsets.only(left: AppSizes.paddingLarge),
                            child: _useJoystick
                                ? BrakeButton(
                                    onPressed: () =>
                                        controller.setBrakeState(true),
                                    onReleased: () =>
                                        controller.setBrakeState(false),
                                    width: 100,
                                    height: 150,
                                    isRightBrake: true,
                                  )
                                : SpeedSlider(
                                    value: _maxSpeed,
                                    onChanged: (value) {
                                      _handleSpeedChange(value);
                                    },
                                    width: 80,
                                    height: 180,
                                    isRightSide: true,
                                  ),
                          ),
                        ],
                ),
              ),
              Positioned(
                bottom: AppSizes.paddingXLarge,
                left: _controlsOnLeft ? null : AppSizes.paddingXLarge + 20,
                right: _controlsOnLeft ? AppSizes.paddingXLarge + 20 : null,
                child: _useJoystick
                    ? CustomJoystick(
                        listener: controller.updateJoystickPosition,
                      )
                    : ArrowControls(
                        onControlUpdate: controller.updateJoystickPosition,
                        onBrakePressed: controller.setBrakeState,
                        maxSpeed: _maxSpeed,
                        holdSteering: _holdSteering, // Pass the current value
                        controlsOnLeft: _controlsOnLeft, // Pass the control position
                        onToggleHoldSteering: (value) {
                          setState(() {
                            _holdSteering = value;
                          });
                        },
                      ),
              ),
              if (_showDebugOverlay) DebugOverlay(controller: controller),
            ],
          ),
        );
      },
    );
  }
}
