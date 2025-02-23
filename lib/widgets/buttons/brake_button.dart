import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrakeButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final double width;
  final double height;

  const BrakeButton({
    super.key,
    required this.onPressed,
    required this.onReleased,
    this.width = 100,
    this.height = 150,
  });

  @override
  State<BrakeButton> createState() => _BrakeButtonState();
}

class _BrakeButtonState extends State<BrakeButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.heavyImpact();
    widget.onPressed();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onReleased();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    widget.onReleased();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(0, _isPressed ? 10 : 0, 0),
        child: Image.asset('lib/assets/images/brake.png', fit: BoxFit.cover),
      ),
    );
  }
}
