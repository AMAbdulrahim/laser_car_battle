import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class ArrowControls extends StatefulWidget {
  final Function(double x, double y) onControlUpdate;
  final Function(bool) onBrakePressed;
  final double maxSpeed; 
  final bool holdSteering;  // Whether steering holds position when released
  final ValueChanged<bool>? onToggleHoldSteering; // Add this callback
  final bool controlsOnLeft; // Add this parameter

  const ArrowControls({
    required this.onControlUpdate,
    required this.onBrakePressed,
    this.maxSpeed = 1.0, // Default to 1.0 if not provided
    this.holdSteering = false,  // Default to auto-centering
    this.onToggleHoldSteering, // Add callback parameter
    this.controlsOnLeft = true, // Default to left side
    super.key,
  });

  @override
  ArrowControlsState createState() => ArrowControlsState();
}

class ArrowControlsState extends State<ArrowControls> with SingleTickerProviderStateMixin {
  // X (direction) and Y (speed) values
  double x = 0.0;
  double y = 0.0;
  double speedMultiplier = 0.0;
  
  bool isBrakePressed = false;
  
  // constants for control feel
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
      // Only stop if values are effectively zero or if we're not holding steering
      bool shouldStop = !_isAnyKeyPressed() && 
                       (y.abs() < threshold) && 
                       (widget.holdSteering ? true : x.abs() < threshold);
                       
      if (shouldStop) {
        _ticker.stop();
        _isTickerActive = false;
        // Send exact zero for Y, but keep X if holdSteering is true
        if (mounted) {
          y = 0.0;
          _lastY = 0.0;
          
          // Only reset X if we're not holding steering
          if (!widget.holdSteering) {
            x = 0.0;
            _lastX = 0.0;
          }
          
          widget.onControlUpdate(x, y);
        }
      }
    }
  }

  /// Main control logic that processes input and calculates new control values at each frame
  /// This function handles:
  /// 1. Speed and direction smoothing with acceleration/deceleration
  /// 2. Steering behavior including auto-centering or hold-in-place
  /// 3. Conversion of button presses to proportional control values
  /// 4. Precise value clamping and rounding to avoid visual jitter
  /// @param elapsed Time elapsed since last frame (not currently used but available)
  void _updateState(Duration elapsed) {
    
    double targetX = 0.0;  // Target steering value (-1.0 = full left, 1.0 = full right)
    double targetY = 0.0;  // Target speed value (positive = forward, negative = reverse)

    // Handle acceleration multiplier with minimum speed
    // This creates a smoother feel when starting and stopping
    if (_isAnyKeyPressed()) {
      // When keys are pressed, accelerate from current speed to target speed
      // Formula ensures we maintain at least minSpeed once movement begins
      // and approach full speed (1.0) as user continues to hold the button
      speedMultiplier = ((speedMultiplier + acceleration) * (1.0 - minSpeed) + minSpeed)
          .clamp(minSpeed, 1.0);
    } else {
      // When no keys are pressed, gradually decelerate to zero
      speedMultiplier = (speedMultiplier - deceleration).clamp(0.0, 1.0);
    }

    // Set target values based on pressed keys
    // Left/right control steering (X axis) and also affect speed (Y axis)
    // Up/down control only speed (Y axis)
    if (keyPressed["left"] == true) {
      targetX = -1.0;               // Full left steering
      targetY = widget.maxSpeed;    // Forward at maximum configured speed
    } else if (keyPressed["right"] == true) {
      targetX = 1.0;                // Full right steering
      targetY = widget.maxSpeed;    // Forward at maximum configured speed
    } else if (keyPressed["up"] == true) {
      targetY = widget.maxSpeed;    // Forward at maximum configured speed (no steering)
    } else if (keyPressed["down"] == true) {
      targetY = -widget.maxSpeed;   // Reverse at maximum configured speed (no steering)
    }

    // Steering logic (X-axis)
    if (targetX != 0) {
      // Calculate step size for smooth steering transition based on current speed
      double step = (targetX - x).sign * sensitivity * speedMultiplier;
      
      // Check if we're already at or beyond the target and still pressing in that direction
      if ((targetX > 0 && x >= targetX) || (targetX < 0 && x <= targetX)) {
        // We're already at or beyond maximum in the desired direction
        // Maintain the current value (prevents oscillation at extremes)
        x = x;  // This line has no effect but clarifies intent
      }
      else if ((targetX - x).abs() < sensitivity) {
        // When close enough to target value, snap exactly to it 
        // This avoids floating point precision issues near target values
        x = targetX;
      } 
      else {
        // Normal case: gradually move toward target steering value
        // with step size proportional to current speed
        x = (x + step).clamp(-1.0, 1.0);
      }
    } else if (!widget.holdSteering) {
      // Auto-center steering when no left/right input and auto-centering is enabled
      if (x.abs() < sensitivity) {
        // When close enough to center, snap exactly to zero
        x = 0;
      } else {
        // Gradually reduce steering angle toward zero (center position)
        x -= x.sign * sensitivity;
      }
    }
    // Note: If holdSteering is true and targetX is 0, we do nothing,
    // which keeps the steering at its current position

    // Speed control logic (Y-axis) - similar to steering but always auto-centers
    if (targetY != 0) {
      // Calculate step size for smooth acceleration/deceleration
      double step = (targetY - y).sign * sensitivity * speedMultiplier;
      if ((targetY - y).abs() < sensitivity) {
        // When close enough to target, set speed proportional to speedMultiplier
        // This creates a gradual acceleration effect
        y = targetY * speedMultiplier;
      } else {
        // Gradually approach target speed
        y += step;
      }
    } else {
      // Decelerate to zero when no throttle input
      if (y.abs() < sensitivity) {
        // When close enough to zero, snap to exact zero
        y = 0;
      } else {
        // Gradually reduce speed toward zero
        y -= y.sign * sensitivity;
      }
    }

    // Final value clamping to ensure values stay within valid ranges
    x = x.clamp(-1.0, 1.0);  // Steering is always between -1.0 and 1.0
    y = y.clamp(-widget.maxSpeed, widget.maxSpeed);  // Speed is limited by maxSpeed parameter

    // Round values to 3 decimal places to prevent tiny floating point error accumulation
    x = double.parse(x.toStringAsFixed(3));
    y = double.parse(y.toStringAsFixed(3));

    // Additional zero snapping for more responsive control feel
    // Values below threshold are considered as zero to prevent tiny unwanted movements
    if (x.abs() < threshold) x = 0.0;
    if (y.abs() < threshold) y = 0.0;

    // Only send updates when values change significantly enough to matter
    // This reduces unnecessary state updates and network traffic
    if (_isSignificantChange(x, _lastX) || _isSignificantChange(y, _lastY)) {
      _lastX = x;
      _lastY = y;
      // Notify parent component about the new control values
      widget.onControlUpdate(x, y);
      // Update UI if still mounted
      if (mounted) {
        setState(() {});
      }
    }

    // Check if the animation ticker should be stopped
    // (e.g., when car has stopped and no inputs are active)
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
    return Stack(
      children: [
        // Main controls column - unchanged
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // First row - Up arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _arrowButton("up", Icons.arrow_upward),
              ],
            ),
            
            // Second row - Left, Brake, Right
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _arrowButton("left", Icons.arrow_back),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                  child: _brakeButton(),
                ),
                _arrowButton("right", Icons.arrow_forward),
              ],
            ),
            
            // Third row - Just the down arrow, no lock button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _arrowButton("down", Icons.arrow_downward),
              ],
            ),
          ],
        ),
        
        // The auto-toggle button positioned based on control side
        Positioned(
          bottom: 15,
          left: widget.controlsOnLeft ? 15 : null, // Left position if controls are on left
          right: widget.controlsOnLeft ? null : 15, // Right position if controls are on right
          child: _buildAutoToggleButton(),
        ),
      ],
    );
  }

  // In the _arrowButton method, modify to show a persistent highlight for left/right when steering is held
  Widget _arrowButton(String key, IconData icon) {
    // Check if this is a steering button that should be highlighted when held
    bool isSteeringHeld = widget.holdSteering && 
                         (key == "left" || key == "right") && 
                         ((key == "left" && x < -0.05) || (key == "right" && x > 0.05));
                         
    return GestureDetector(
      onTapDown: (_) => _onKeyChange(key, true),
      onTapUp: (_) => _onKeyChange(key, false),
      onTapCancel: () => _onKeyChange(key, false),
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (keyPressed[key] == true || isSteeringHeld) 
                 ? CustomColors.joystickBase 
                 : CustomColors.joystickKnob,
        ),
        child: Icon(
          icon, 
          color: (keyPressed[key] == true || isSteeringHeld) 
                 ? CustomColors.joystickKnob 
                 : CustomColors.joystickBase,
          size: 36,
        ),
      ),
    );
  }

  // Brake button widget that changes appearance when pressed
  // Sends brake events to the parent component through onBrakePressed callback
  Widget _brakeButton() {
    return GestureDetector(
      // Activate brake when touch begins
      onTapDown: (_) {
        setState(() => isBrakePressed = true);
        widget.onBrakePressed(true);  // Notify parent component that brake is active
      },
      // Deactivate brake when touch ends
      onTapUp: (_) {
        setState(() => isBrakePressed = false);
        widget.onBrakePressed(false);  // Notify parent component that brake is released
      },
      // Handle case where gesture is cancelled (e.g., drag away)
      onTapCancel: () {
        setState(() => isBrakePressed = false);
        widget.onBrakePressed(false);  // Ensure brake is released if touch is cancelled
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,  // Square shape for brake button for visual distinction
          borderRadius: BorderRadius.circular(10), // Rounded corners for better visual appearance
          // Invert colors when pressed to provide visual feedback
          color: !isBrakePressed ? CustomColors.joystickBase : CustomColors.joystickKnob,
        ),
        child: Center(
          child: Text(
            "BRAKE",
            style: TextStyle(
              // Text color also inverts when pressed for contrast
              color: !isBrakePressed ? CustomColors.joystickKnob : CustomColors.joystickBase,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // Creates a toggle button for switching between auto-centering and fixed steering modes
  // This affects whether the steering returns to center when left/right arrows are released
  Widget _buildAutoToggleButton() {
    return GestureDetector(
      onTap: () {
        if (widget.onToggleHoldSteering != null) {
          widget.onToggleHoldSteering!(!widget.holdSteering);
        }
      },
      child: Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.all(5), // Consistent margin on all sides
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.holdSteering ? 
            CustomColors.joystickBase.withOpacity(0.8) : 
            CustomColors.joystickKnob.withOpacity(0.8),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            widget.holdSteering ? 
              Icons.lock_outline : 
              Icons.lock_open,
            color: widget.holdSteering ? 
              Colors.white : 
              CustomColors.joystickBase,
            size: 18,
          ),
        ),
      ),
    );
  }

}
