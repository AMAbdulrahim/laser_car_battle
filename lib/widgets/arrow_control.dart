import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';

class ArrowControls extends StatefulWidget {
  final Function(double x, double y) onControlUpdate;

  const ArrowControls({required this.onControlUpdate, Key? key}) : super(key: key);

  @override
  _ArrowControlsState createState() => _ArrowControlsState();
}

class _ArrowControlsState extends State<ArrowControls> with SingleTickerProviderStateMixin {
  // X (direction) and Y (speed) values
  double x = 0.0;
  double y = 0.0;
  double speedMultiplier = 0.0;  // New: tracks acceleration progress
  
  // Constants for control feel
  final double maxValue = 1.0;    // Maximum value for both x and y [-1.0, 1.0]
  final double minSpeed = 0.15;    // Minimum initial speed
  final double acceleration = 0.02;    // Rate of acceleration (takes ~50 frames to max)
  final double deceleration = 0.04;    // Rate of deceleration (faster than accel)
  final double threshold = 0.02;       // Zero-snap threshold
  final double sensitivity = 0.02;     // Movement granularity
  final double epsilon = 0.001;  // Smallest significant difference
  
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

    // Determine targets based on pressed keys
    if (keyPressed["left"] == true) {
      targetX = -maxValue;
      targetY = maxValue;
    } else if (keyPressed["right"] == true) {
      targetX = maxValue;
      targetY = maxValue;
    } else if (keyPressed["up"] == true) {
      targetY = maxValue;
    } else if (keyPressed["down"] == true) {
      targetY = -maxValue;
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

    // Apply speed multiplier to Y movement
    if (targetY != 0) {
      double step = (targetY - y).sign * sensitivity * speedMultiplier;
      if ((targetY - y).abs() < sensitivity) {
        y = targetY * speedMultiplier;
      } else {
        y += step;
      }
    } else {
      // Decelerate in steps
      if (y.abs() < sensitivity) {
        y = 0;
      } else {
        y -= y.sign * sensitivity;
      }
    }

    // Clamp values
    x = x.clamp(-maxValue, maxValue);
    y = y.clamp(-maxValue, maxValue);

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
            const SizedBox(width: 75),
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
        ),      ),
    );
  }
}
