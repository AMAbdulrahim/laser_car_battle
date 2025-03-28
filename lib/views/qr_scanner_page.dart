import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  late MobileScannerController controller;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight+20),
        child: CustomAppBar(
          titleText: "Scan QR Code",
          showLeading: true,  
        ),
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              
              // Only process if we're still scanning
              if (!_isScanning) return;
              
              for (final barcode in barcodes) {
                // Check if the barcode value is exactly 4 digits (game code)
                final value = barcode.rawValue;
                if (value != null && value.length == 4 && int.tryParse(value) != null) {
                  // Mark as no longer scanning to prevent multiple callbacks
                  setState(() {
                    _isScanning = false;
                  });
                  
                  // Vibrate for feedback
                  HapticFeedback.mediumImpact();
                  
                  // Return to the previous screen with the code
                  Navigator.pop(context, value);
                  return;
                }
              }
            },
          ),
          
          // Scan overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: CustomColors.mainButton,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // Help text
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: const Text(
                'Point camera at game QR code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}