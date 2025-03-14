# ArrowControls Widget Documentation

## Overview
`ArrowControls` is a customizable directional control widget for controlling movement in games or simulations. It provides arrow buttons for directional input (up, down, left, right), a brake button, and optional steering lock functionality.

## Features
- Four directional arrow buttons
- Dedicated brake button
- Configurable maximum speed
- Optional steering lock mode that maintains steering angle when controls are released
- Configurable positioning (left or right side of the screen)
- Smooth acceleration and deceleration physics
- Minimal value change detection to prevent unnecessary updates

## Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `onControlUpdate` | `Function(double x, double y)` | Callback that receives steering (x) and acceleration (y) values. Both range from -1.0 to 1.0. | **required** |
| `onBrakePressed` | `Function(bool)` | Callback triggered when brake button is pressed or released. | **required** |
| `maxSpeed` | `double` | Maximum speed multiplier applied to the y-axis value. | `1.0` |
| `holdSteering` | `bool` | When true, steering position is maintained after releasing controls. When false, steering auto-centers. | `false` |
| `onToggleHoldSteering` | `ValueChanged<bool>?` | Optional callback when steering lock button is pressed. | `null` |
| `controlsOnLeft` | `bool` | When true, positions the controls on the left side of the container. | `true` |

## Control Behavior
- **X-Axis (Steering)**: Ranges from -1.0 (full left) to 1.0 (full right).
- **Y-Axis (Speed)**: Ranges from -maxSpeed (full reverse) to maxSpeed (full forward).
- **Acceleration**: Speed gradually increases when direction is held down.
- **Auto-centering**: When `holdSteering` is false, steering gradually returns to center (0.0) when released.
- **Brake**: When pressed, triggers the `onBrakePressed` callback with a value of `true`.

## Usage Example

```dart
ArrowControls(
  onControlUpdate: (double x, double y) {
    // Handle movement updates
    // x: -1.0 (full left) to 1.0 (full right)
    // y: -1.0 (full reverse) to 1.0 (full forward)
    print('Steering: $x, Acceleration: $y');
  },
  onBrakePressed: (bool isPressed) {
    // Handle brake press/release
    print('Brake ${isPressed ? 'pressed' : 'released'}');
  },
  maxSpeed: 0.8,  // Limit maximum speed to 80%
  holdSteering: true,  // Enable steering lock
  onToggleHoldSteering: (bool isLocked) {
    // Handle steering lock mode change
    print('Steering lock ${isLocked ? 'enabled' : 'disabled'}');
  },
  controlsOnLeft: false,  // Position controls on right side
),
```

## Internal Mechanics

### Acceleration and Deceleration
The widget implements smooth acceleration and deceleration physics with:
- Minimum speed threshold for immediate response
- Gradual speed increase when holding direction
- Smooth deceleration when releasing controls

### Steering Lock
When `holdSteering` is enabled:
- Steering position is maintained after releasing controls
- The lock/unlock button shows the current state
- Left/right buttons show a persistent highlight when steering is locked in that direction

### Performance Optimization
- Uses a ticker for efficient animation
- Only sends updates on significant value changes
- Auto-stops animation when no input is detected

## Design
- Directional buttons are circular with icon indicators
- Brake button is rectangular with text label
- Steering lock button is circular with lock/unlock icon
- Colors adapt based on active/inactive states
