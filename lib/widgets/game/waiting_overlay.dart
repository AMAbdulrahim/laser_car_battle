import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';

class WaitingOverlay extends StatefulWidget {
  final String gameCode;
  final VoidCallback onCancel;

  const WaitingOverlay({
    super.key,
    required this.gameCode,
    required this.onCancel,
  });

  @override
  State<WaitingOverlay> createState() => _WaitingOverlayState();
}

class _WaitingOverlayState extends State<WaitingOverlay> {
  late Timer _timer;
  int _elapsedSeconds = 0;
  bool _showQrCode = false;
  
  String get formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _toggleQrCode() {
    setState(() {
      _showQrCode = !_showQrCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base waiting overlay
        Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Card(
              color: CustomColors.background,
              shadowColor: CustomColors.appBarBackground,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 330,
                padding: const EdgeInsets.all(24),
                child: _buildGameCodeView(),
              ),
            ),
          ),
        ),
        
        // QR Code overlay (conditional)
        if (_showQrCode) _buildQrCodeOverlay(),
      ],
    );
  }

  Widget _buildQrCodeOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.95),
      child: Center(
        child: Card(
          color: CustomColors.background,
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: CustomColors.buttonText),
                      onPressed: _toggleQrCode,
                    ),
                    const Text(
                      'QR Code',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the row
                  ],
                ),
                const SizedBox(height: 20),
                
                // QR Code
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: QrImageView(
                    data: widget.gameCode,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 10),
                const Text(
                  'Have your opponent scan this code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CustomColors.buttonText,
                    fontSize: 16,
                  ),
                ),
               
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCodeView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Waiting for Opponent',
          style: TextStyle(
            color: CustomColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        const Text(
          'Game Code',
          style: TextStyle(
            color: CustomColors.buttonText,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: CustomColors.mainButton,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.gameCode,
                style: const TextStyle(
                  color: CustomColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code, color: CustomColors.fireButton),
                onPressed: _toggleQrCode,
                tooltip: 'Show QR Code',
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        Column(
          children: [
            const Text(
              'Waiting time:',
              style: TextStyle(
                color: CustomColors.buttonText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedTime,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            backgroundColor: Colors.red.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Cancel Waiting',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}