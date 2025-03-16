# Laser Car Battle

A mobile application for controlling and playing with laser-equipped RC cars using Bluetooth Low Energy (BLE) technology.

![Laser Car Battle](assets/images/app_preview.png)

## Features

### BLE Connectivity
- Real-time control of ESP32-powered RC cars
- Automatic device discovery and connection management
- Robust command protocol for precise car control
- Support for multiple connected devices (Player 1 and Player 2 cars)

### Game Modes
- **Points Mode**: First player to reach a target number of points wins
- **Time Mode**: Player with the most points when time expires wins
- Configurable game parameters (time duration, point targets)

### Car Controls
- Multiple control options:
  - Joystick control with sensitivity adjustment
  - Arrow key controls with customizable steering behavior
  - Speed slider for maximum velocity control
- Brake button with responsive feedback
- Fire button with cooldown mechanism and haptic feedback

### Visual Feedback
- Real-time dashboard with:
  - Speedometer gauge showing current velocity
  - Steering indicator displaying wheel position
  - Direction arrow showing forward/reverse status
- Score board with player names and points
- Game insights widget showing current mode and target

### Multiplayer Features
- Two-player local gameplay
- Individual player profiles with customizable names
- Hit detection and scoring system
- Leaderboard with game history and filtering options

### Development Tools
- Debug overlay for control state monitoring
- Visual indicators for all control inputs
- Customizable control layouts (left/right positioning)
- Multiple visualization options

## Implementation

### Architecture
- **MVVM Design Pattern**: Clear separation between UI, business logic and data layers
- **Provider State Management**: Reactive state handling with the Provider pattern
- **Service Layer**: Abstraction for hardware communication and data persistence

### Key Components
- `BluetoothService`: Manages BLE device scanning, connections, and communication
- `GameViewModel`: Controls game flow, scoring, and round management
- `CarControllerViewModel`: Handles car control inputs and feedback
- `LeaderboardViewModel`: Manages game history and filtering

### Technologies Used
- Flutter and Dart for cross-platform development
- Flutter Reactive BLE package for Bluetooth communication
- Supabase for online leaderboard data storage
- Custom UI components for precise control interfaces

## Getting Started

### Prerequisites
- Flutter SDK (2.10 or later)
- Mobile device with BLE support
- Laser Car hardware with ESP32 controller

### Installation
1. Clone the repository
2. Create a `.env` file with the following content:
    - SUPABASE_URL, SUPABASE_ANON_KEY, BLE_SERVICE_UUID, and BLE_CHARACTERISTIC_UUID


3. Run `flutter pub get` to install dependencies
4. Connect to your laser car hardware
5. Run `flutter run` to start the application

## Hardware Requirements

This application requires custom-built RC cars with:
- ESP32 microcontroller
- Bluetooth Low Energy (BLE) capability
- Laser emitter
- Light sensors for hit detection
- Motor control system

## Future Enhancements
- Power-ups and special abilities
- Tournament mode
- Statistics tracking and achievements
- Sound effects and background music

## License

