import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class ArrowControls extends StatefulWidget {
  final Function(double x, double y) onControlUpdate;
  final Function(bool) onBrakePressed;
  final double maxSpeed; // Add this parameter

  const ArrowControls({
    required this.onControlUpdate,
    required this.onBrakePressed,
    this.maxSpeed = 1.0, // Default to 1.0 if not provided
    Key? key,
  }) : super(key: key);

  @override
  _ArrowControlsState createState() => _ArrowControlsState();
}

class _ArrowControlsState extends State<ArrowControls> with SingleTickerProviderStateMixin {
  // X (direction) and Y (speed) values
  double x = 0.0;
  double y = 0.0;
  double speedMultiplier = 0.0;
  
  bool isBrakePressed = false;
  
  // Other constants for control feel
  final double minSpeed = 0.15;
  final double acceleration = 0.02;
  final double deceleration = 0.04;
  final double threshold = 0.02;
  final double sensitivity = 0.02;
  final double epsilon = 0.001;
  
  Map<String, bool> keyPressed = {
    "up": false,
    "down": false,
    "left": false,
    "right": false,
  };

  late Ticker _ticker;
  double _lastX = 0.0;
  double _lastY = 0.0;
  bool _isTickerActive = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      _updateState(elapsed);
    });
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    // Clear any pressed keys
    keyPressed.clear();
    // Send final zero update
    if (mounted) {
      widget.onControlUpdate(0.0, 0.0);
    }
    super.dispose();
  }

  void _startTicker() {
    if (!_isTickerActive) {
      _ticker.start();
      _isTickerActive = true;
    }
  }

  void _stopTicker() {
    if (_isTickerActive) {
      // Only stop if values are effectively zero
      if (!_isAnyKeyPressed() && x.abs() < threshold && y.abs() < threshold) {
        _ticker.stop();
        _isTickerActive = false;
        // Send exact zero
        if (mounted) {
          x = 0.0;
          y = 0.0;
          _lastX = 0.0;
          _lastY = 0.0;
          widget.onControlUpdate(0.0, 0.0);
        }
      }
    }
  }

  void _updateState(Duration elapsed) {
    if (!mounted) return;
    
    double targetX = 0.0;
    double targetY = 0.0;

    // Handle acceleration multiplier with minimum speed
    if (_isAnyKeyPressed()) {
      speedMultiplier = ((speedMultiplier + acceleration) * (1.0 - minSpeed) + minSpeed)
          .clamp(minSpeed, 1.0);
    } else {
      speedMultiplier = (speedMultiplier - deceleration).clamp(0.0, 1.0);
    }

    // Use widget.maxSpeed instead of constant maxValue or _maxValue
    if (keyPressed["left"] == true) {
      targetX = -1.0; // X value is always full
      targetY = widget.maxSpeed; // Y is scaled by maxSpeed
    } else if (keyPressed["right"] == true) {
      targetX = 1.0; // X value is always full
      targetY = widget.maxSpeed; // Y is scaled by maxSpeed
    } else if (keyPressed["up"] == true) {
      targetY = widget.maxSpeed; // Y is scaled by maxSpeed
    } else if (keyPressed["down"] == true) {
      targetY = -widget.maxSpeed; // Y is scaled by maxSpeed
    }

    // Apply speed multiplier to movement with minimum speed
    if (targetX != 0) {
      double step = (targetX - x).sign * sensitivity * speedMultiplier;
      if ((targetX - x).abs() < sensitivity) {
        x = targetX * speedMultiplier;
      } else {
        x += step;
      }
    } else {
      // Decelerate in steps
      if (x.abs() < sensitivity) {
        x = 0;
      } else {
        x -= x.sign * sensitivity;
      }
    }

    // Similar update for Y movement
    if (targetY != 0) {
      double step = (targetY - y).sign * sensitivity * speedMultiplier;
      if ((targetY - y).abs() < sensitivity) {
        y = targetY * speedMultiplier;
      } else {
        y += step;
      }
    } else {
      if (y.abs() < sensitivity) {
        y = 0;
      } else {
        y -= y.sign * sensitivity;
      }
    }

    // Only clamp Y value using maxSpeed
    x = x.clamp(-1.0, 1.0);
    y = y.clamp(-widget.maxSpeed, widget.maxSpeed);

    // Round values to prevent floating point errors
    x = double.parse(x.toStringAsFixed(3));
    y = double.parse(y.toStringAsFixed(3));

    // More aggressive zero snapping
    if (x.abs() < threshold) x = 0.0;
    if (y.abs() < threshold) y = 0.0;

    // Only send updates for significant changes
    if (_isSignificantChange(x, _lastX) || _isSignificantChange(y, _lastY)) {
      _lastX = x;
      _lastY = y;
      widget.onControlUpdate(x, y);
      if (mounted) {
        setState(() {});
      }
    }

    // Check if we can stop the ticker after update
    _stopTicker();
  }

  bool _isAnyKeyPressed() {
    return keyPressed.values.any((pressed) => pressed);
  }

  void _onKeyChange(String key, bool isPressed) {
    if (!mounted) return;
    
    setState(() {
      keyPressed[key] = isPressed;
    });

    // Start ticker when key is pressed
    if (isPressed) {
      _startTicker();
    } else {
      // Check if we should stop the ticker after key release
      _stopTicker();
    }
  }

  bool _isSignificantChange(double a, double b) {
    return (a - b).abs() > epsilon;
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 20.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _arrowButton("up", Icons.arrow_upward),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _arrowButton("left", Icons.arrow_back),
            //const SizedBox(width: spacing),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              child: _brakeButton(),
            ), // Keep brake button in middle
            //const SizedBox(width: spacing),
            _arrowButton("right", Icons.arrow_forward),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _arrowButton("down", Icons.arrow_downward),
          ],
        ),
      ],
    );
  }

  Widget _arrowButton(String key, IconData icon) {
    return GestureDetector(
      onTapDown: (_) => _onKeyChange(key, true),
      onTapUp: (_) => _onKeyChange(key, false),
      onTapCancel: () => _onKeyChange(key, false),
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: keyPressed[key] == true ? CustomColors.joystickBase : CustomColors.joystickKnob,
        ),
        child: Icon(
          icon, 
          color: keyPressed[key] == true ? CustomColors.joystickKnob : CustomColors.joystickBase,
          size: 36, // Add explicit icon size
        ),
      ),
    );
  }

  // Update brake button to be square with text
  Widget _brakeButton() {
    // Return empty space if no brake handler
    if (widget.onBrakePressed == null) {
      return SizedBox(width: 75, height: 75);
    }

    return GestureDetector(
      onTapDown: (_) {
        setState(() => isBrakePressed = true);
        widget.onBrakePressed(true);
      },
      onTapUp: (_) {
        setState(() => isBrakePressed = false);
        widget.onBrakePressed(false);
      },
      onTapCancel: () {
        setState(() => isBrakePressed = false);
        widget.onBrakePressed(false);
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,  // Changed to square
          borderRadius: BorderRadius.circular(10), // Slightly rounded corners
          color: !isBrakePressed ? CustomColors.joystickBase : CustomColors.joystickKnob,
        ),
        child: Center(
          child: Text(
            "BRAKE",
            style: TextStyle(
              color: !isBrakePressed ? CustomColors.joystickKnob : CustomColors.joystickBase,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  

}
