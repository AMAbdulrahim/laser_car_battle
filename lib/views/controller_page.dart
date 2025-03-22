import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/models/bluetooth_device.dart';
import 'package:laser_car_battle/models/car_type.dart';
import 'package:laser_car_battle/widgets/control/controller_header.dart';
import 'package:laser_car_battle/widgets/control/control_layout.dart';
import 'package:laser_car_battle/widgets/dashboard/dashboard_display.dart';
import 'package:laser_car_battle/widgets/debug/debug_overlay.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';

class RemoteController extends StatefulWidget {
  const RemoteController({super.key});

  @override
  State<RemoteController> createState() => _RemoteControllerState();
}

class _RemoteControllerState extends State<RemoteController> {
  bool _controlsOnLeft = true;
  bool _showDebugOverlay = false;
  bool _useJoystick = true;
  bool _useVisualIndicator = false;
  double _maxSpeed = 1.0;
  bool _holdSteering = false;
  late final GameViewModel _gameViewModel;

  void _handleSpeedChange(double value) {
    setState(() => _maxSpeed = value);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameViewModel = Provider.of<GameViewModel>(context, listen: false);

      // Enable debug mode with confirmation
      _gameViewModel.setDebugBypassActiveCheck(true);
      print("DEBUG MODE ENABLED: ${_gameViewModel.debugBypassActiveCheck}");
      
      // Add mock cars for debugging
      _gameViewModel.setCar1(BluetoothDevice(
        id: 'mock-car1-id',
        name: 'Car1',
        carType: CarType.car1,
      ));
      
      _gameViewModel.setCar2(BluetoothDevice(
        id: 'mock-car2-id',
        name: 'Car2',
        carType: CarType.car2,
      ));

      _gameViewModel.onGameOver = () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/game-over',
            (Route<dynamic> route) => false,
          );
        }
      };

      // Only start the game if not waiting for players
      if (!_gameViewModel.waitingForPlayers) {
        _gameViewModel.startGame();
      }
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Only stop the game if we're not in debug bypass mode
    if (!_gameViewModel.debugBypassActiveCheck) {
      _gameViewModel.stopGame();
    } else {
      // In debug mode, just log that we're keeping the game active
      print("DEBUG MODE: Keeping game active on controller page dispose");
    }
    
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
              // Header section (settings, insights, scoreboard)
              ControllerHeader(
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
                onToggleVisualMode: () {  
                  setState(() {
                    _useVisualIndicator = !_useVisualIndicator;
                  });
                },
              ),
              
              // Dashboard/visual indicator
              Positioned(
                top: 180,
                left: 0,
                right: 0,
                child: DashboardDisplay(
                  speed: controller.yAxis,
                  angle: controller.xAxis,
                  maxSpeed: _maxSpeed,
                  useVisualIndicator: _useVisualIndicator,
                ),
              ),
              
              // Controls (joystick/arrows, fire, brake)
              ControlLayout(
                controlsOnLeft: _controlsOnLeft,
                useJoystick: _useJoystick,
                maxSpeed: _maxSpeed,
                holdSteering: _holdSteering,
                controller: controller,
                onSpeedChanged: _handleSpeedChange,
                onToggleHoldSteering: (value) {
                  setState(() {
                    _holdSteering = value;
                  });
                },
              ),
              
              // Debug overlay
              if (_showDebugOverlay) DebugOverlay(controller: controller),
            ],
          ),
        );
      },
    );
  }
}
