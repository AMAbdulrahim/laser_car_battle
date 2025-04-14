import 'package:flutter/material.dart';
import 'package:laser_car_battle/services/bluetooth_service.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/bluetooth_viewmodel.dart';
import 'package:laser_car_battle/widgets/buttons/action_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:laser_car_battle/widgets/insights/status_card.dart';
import 'package:provider/provider.dart';

class BluetoothPage extends StatelessWidget {
  BluetoothPage({super.key});
  
  final BluetoothService _bluetoothService = BluetoothService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight+10),
        child: CustomAppBar(
          titleText: "Connect",
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Consumer2<PlayerViewModel, BluetoothViewModel>(
                  builder: (context, playerViewModel, bluetoothViewModel, child) {
                    final isConnectedPlayer = bluetoothViewModel.connectedDevice != null;
                    //final isConnectedOpponent = isConnectedPlayer;
                    
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: AppSizes.paddingLarge * 4,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: Text(
                            "Hi, ${playerViewModel.playerName.isEmpty ? 'Player' : playerViewModel.playerName}",
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
                        
                        InkWell(
                          onTap: () {
                            if (!isConnectedPlayer) {
                              _showDeviceDialog(context, bluetoothViewModel);
                            }
                          },
                          child: StatusCard(
                            checkStatus: isConnectedPlayer,
                            statusText: isConnectedPlayer 
                                ? "Connected to ${bluetoothViewModel.connectedDevice?.name}"
                                : "Tap to connect", 
                          ),
                        ),
                        
                        // SizedBox(height: AppSizes.paddingLarge),
                        
                        // StatusCard(
                        //   checkStatus: isConnectedOpponent,
                        //   statusText: "Opponent", 
                        // ),
                        
                        SizedBox(height: AppSizes.paddingLarge * 1.5),
                        
                        if (bluetoothViewModel.isScanning)
                          //CircularProgressIndicator(),
                          
                        SizedBox(height: AppSizes.paddingLarge),
                          
                        if (!isConnectedPlayer)
                          ActionButton(
                            onPressed: () {
                              bluetoothViewModel.startScan();
                            },
                            buttonText: bluetoothViewModel.isScanning ? "Scanning..." : "Scan for Cars", 
                          ),
                          
                        if (isConnectedPlayer)
                          ActionButton(
                            onPressed: () {
                              bluetoothViewModel.disconnectDevice();
                            },
                            buttonText: "Disconnect", 
                          ),
                          
                        if ( isConnectedPlayer) ...[
                          SizedBox(height: AppSizes.paddingLarge),
                          ActionButton(
                            onPressed: () {
                               if (bluetoothViewModel.isScanning) {
                              bluetoothViewModel.stopScan();
                            }
                              Navigator.pushNamed(context, '/gameMode');
                            },
                            buttonText: "Game Mode", 
                          ),
                        ]
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showDeviceDialog(BuildContext context, BluetoothViewModel bluetoothViewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select your Car"),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (bluetoothViewModel.devices.isEmpty && !bluetoothViewModel.isScanning)
                      Text("No cars found. Press Scan to search."),
                      
                    if (bluetoothViewModel.isScanning)
                      CircularProgressIndicator(),
                      
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: bluetoothViewModel.devices.length,
                      itemBuilder: (context, index) {
                        final device = bluetoothViewModel.devices[index];
                        return ListTile(
                          title: Text(device.name),
                          subtitle: Text(_bluetoothService.isValidCarDevice(device.name) 
                              ? device.carType.toString() 
                              : "Other device"),
                          trailing: Text("${device.rssi} dBm"),
                          onTap: () {
                            bluetoothViewModel.connectToDevice(device);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                bluetoothViewModel.startScan();
              },
              child: Text("Scan"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
