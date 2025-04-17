import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/bluetooth_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  double _servoX = 0;
  String? _lastReceived;

 @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final btViewModel = Provider.of<BluetoothViewModel>(context, listen: false);
    final gameViewModel = Provider.of<GameViewModel>(context, listen: false);

    final device = btViewModel.connectedDevice;
    if (device != null) {
      gameViewModel.setCar1(device); // ✅ Safe now
    }

    btViewModel.messages.listen((msg) {
      setState(() {
        _lastReceived = msg;
      });
      print("Received from Arduino: $msg");
    });
  });
}


  @override
  Widget build(BuildContext context) {
    final btViewModel = Provider.of<BluetoothViewModel>(context);
    final gameViewModel = Provider.of<GameViewModel>(context);
    final deviceId = btViewModel.connectedDevice?.id;

    return Scaffold(
      backgroundColor: CustomColors.background,
      appBar: AppBar(
        title: const Text("Servo Test"),
        backgroundColor: CustomColors.appBarBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: deviceId == null
            ? const Center(
                child: Text(
                  "❌ No Bluetooth device connected.",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Servo X: ${_servoX.toInt()}  (mapped from -30 to 30)",
                    style: const TextStyle(
                      color: CustomColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
  value: _servoX,
  min: -1.0,
  max: 1.0,
  divisions: 100,
  label: _servoX.toStringAsFixed(2),
  onChanged: (value) {
    setState(() {
      _servoX = value;
    });

    final carId = Provider.of<GameViewModel>(context, listen: false).car1?.id;

    if (carId != null) {
      gameViewModel.sendJoystickControl(carId, _servoX, 0);
    }
    
  },
),

              
                  const SizedBox(height: 32),
                  Text(
                    _lastReceived != null
                        ? "📩 Last received: $_lastReceived"
                        : "No response received yet.",
                    style: const TextStyle(
                      fontSize: AppSizes.fontLarge,
                      color: CustomColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
