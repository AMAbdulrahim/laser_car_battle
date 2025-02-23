import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _FireButtonState extends State<FireButton> with SingleTickerProviderStateMixin {
  bool _isEnabled = true;
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          HapticFeedback.heavyImpact();
          setState(() {
            _isEnabled = true;
          });
          _controller.reset();
        }
      });

    _glowAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _handlePress() {
    if (_isEnabled) {
      HapticFeedback.mediumImpact();
      widget.onPressed();
      setState(() {
        _isEnabled = false;
        _isPressed = true;
      });
      _controller.forward();
      
      // Add visual press effect
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isPressed = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        if (_isEnabled) 
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.size + (_isPressed ? 20 : 0),
            height: widget.size + (_isPressed ? 20 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CustomColors.fireButton.withOpacity(0.3),
                  blurRadius: _isPressed ? 20 : 10,
                  spreadRadius: _isPressed ? 5 : 0,
                ),
              ],
            ),
          ),
        // Cooldown indicator
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            value: 1 - _animation.value,
            strokeWidth: 5,
            backgroundColor: Colors.grey.withOpacity(0.3),
            color: _isEnabled ? CustomColors.fireButton : CustomColors.fireButton.withOpacity(0.5),
          ),
        ),
        // Button
        Transform.scale(
          scale: _isPressed ? 0.95 : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handlePress,
              customBorder: const CircleBorder(),
              child: Container(
                width: widget.size - 20,
                height: widget.size - 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isEnabled 
                      ? CustomColors.fireButton
                      : Colors.grey.withOpacity(0.3),
                  boxShadow: _isEnabled ? [
                    BoxShadow(
                      color: CustomColors.fireButton.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    'FIRE',
                    style: TextStyle(
                      color: _isEnabled ? CustomColors.textPrimary : Colors.grey,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
