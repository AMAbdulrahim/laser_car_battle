import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/models/bluetooth_device.dart';
import 'package:laser_car_battle/models/car_type.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/bluetooth_viewmodel.dart';
import 'package:laser_car_battle/widgets/control/controller_header.dart';
import 'package:laser_car_battle/widgets/control/control_layout.dart';
import 'package:laser_car_battle/widgets/control/quick_toggle_bar.dart';
import 'package:laser_car_battle/widgets/dashboard/dashboard_display.dart';
import 'package:laser_car_battle/widgets/debug/debug_overlay.dart';
import 'package:laser_car_battle/widgets/game/waiting_overlay.dart'; // Add this import
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
  GameViewModel? _gameViewModel;
  CarControllerViewModel? _controllerViewModel;

  void _handleSpeedChange(double value) {
    setState(() => _maxSpeed = value);
  }

 @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
    final btViewModel = Provider.of<BluetoothViewModel>(context, listen: false);

    print("🧩 Host status: ${gameViewModel.isHost}");

    final connectedDevice = btViewModel.connectedDevice;
    if (connectedDevice != null) {
      if (gameViewModel.isHost && gameViewModel.car1 == null) {
        gameViewModel.setCar1(connectedDevice);
        print("✅ Assigned ${connectedDevice.name} to Player 1 (car1)");
      } else if (!gameViewModel.isHost && gameViewModel.car2 == null) {
        gameViewModel.setCar2(connectedDevice);
        print("✅ Assigned ${connectedDevice.name} to Player 2 (car2)");
      }
    } else {
      print("⚠️ No connected device found at controller init");
    }

    // 🧪 In debug mode, assign a mock car to car2 if needed
    if (gameViewModel.debugBypassActiveCheck && gameViewModel.car2 == null) {
      gameViewModel.setCar2(BluetoothDevice(
        id: 'mock-car2-id',
        name: 'Car2',
        carType: CarType.car2,
      ));
      print("🧪 Mock Car2 assigned for solo debug testing.");
    }

    gameViewModel.onGameOver = () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/game-over',
          (Route<dynamic> route) => false,
        );
      }
    };

    if (!gameViewModel.waitingForPlayers) {
      gameViewModel.startGame();
    }
  });

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize only if null to prevent double initialization
    _controllerViewModel ??= Provider.of<CarControllerViewModel>(context);
  }

  @override
  void dispose() {
    // Use null-safe access to prevent errors
    _controllerViewModel?.cleanup();
    
    // Only stop the game if we're not in debug bypass mode
    if (_gameViewModel != null && !_gameViewModel!.debugBypassActiveCheck) {
      _gameViewModel!.stopGame();
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
  
  void _cancelWaiting() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CustomColors.appBarBackgroundExtension,
        title: Text(
          'Cancel Waiting?',
          style: TextStyle(color: CustomColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to cancel waiting for another player?\n This will end the current game!',
          style: TextStyle(color: CustomColors.textPrimary,fontSize: AppSizes.fontLarge, ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, Keep Waiting'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _gameViewModel?.stopGame();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (Route<dynamic> route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
  
  // Update _onWillPop to use null-safe access
  Future<bool> _onWillPop() async {
    // Show confirmation dialog
    final shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: CustomColors.appBarBackground,
        title: Text(
          'Exit Game?',
          style: TextStyle(color: CustomColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to exit!? \nThis will end the current game!',
          style: TextStyle(color: CustomColors.buttonText,
          fontSize: AppSizes.fontLarge),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Use null-safe access
              _controllerViewModel?.cleanup();
              
              // Stop the game properly
              _gameViewModel?.stopGame();
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _onWillPop().then((value) {
            if (value) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (Route<dynamic> route) => false,
              );
            }
          });
        }
      },
      child: Consumer2<CarControllerViewModel, GameViewModel>(
        builder: (context, controller, gameViewModel, child) {
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
                if (_showDebugOverlay) DebugOverlay(
                  controller: controller,
                  gameViewModel: gameViewModel,
                ),
                
                //Quick Toggle Bar positioned at the bottom
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: QuickToggleBar(
                    controlsOnLeft: _controlsOnLeft,
                    useJoystick: _useJoystick,
                    useVisualIndicator: _useVisualIndicator,
                    holdSteering: _holdSteering,
                    onToggleControls: () {
                      setState(() {
                        _controlsOnLeft = !_controlsOnLeft;
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
                    onToggleHoldSteering: () {
                      setState(() {
                        _holdSteering = !_holdSteering;
                      });
                    },
                  ),
                ),
                
                // Add the waiting overlay when in waiting state
if (gameViewModel.isHost && 
    gameViewModel.waitingForPlayers && 
    !gameViewModel.debugBypassActiveCheck)                  WaitingOverlay(
                    gameCode: gameViewModel.gameCode,
                    onCancel: _cancelWaiting,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
