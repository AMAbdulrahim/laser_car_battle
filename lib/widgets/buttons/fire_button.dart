import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'dart:async';

class FireButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;

  const FireButton({
    super.key,
    required this.onPressed,
    this.size = 150,
  });

  @override
  State<FireButton> createState() => _FireButtonState();
}

class _FireButtonState extends State<FireButton> {
  bool _isEnabled = true;
  // int _countdown = 3;
  Timer? _timer;
  final ValueNotifier<int> _countNotifier = ValueNotifier<int>(3);

  void _handlePress() {
    if (_isEnabled) {
      widget.onPressed();
      _isEnabled = false;
      _countNotifier.value = 3;

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countNotifier.value > 0) {
          _countNotifier.value--;
        } else {
          _isEnabled = true;
          timer.cancel();
          setState(() {}); // Single rebuild when enabled
        }
      });
      setState(() {}); // Single rebuild when disabled
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handlePress,
          customBorder: const CircleBorder(),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isEnabled 
                  ? CustomColors.fireButton
                  : Colors.grey.withOpacity(0.3),
            ),
            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: _countNotifier,
                builder: (context, value, child) {
                  return Text(
                    _isEnabled ? 'FIRE' : '$value',
                    style: TextStyle(
                      color: _isEnabled ? CustomColors.textPrimary : Colors.grey,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
