# Arduino Communication Protocol for Laser Car Battle

This document outlines the communication protocol between the Flutter mobile application and Arduino-based laser cars. The protocol uses JSON for message formatting over Serial/Bluetooth communication.

## Communication Overview

- **Protocol**: JSON over Serial/Bluetooth
- **Direction**: Bidirectional (App → Car, Car → App)
- **Encoding**: UTF-8
- **Line Ending**: Each message ends with newline character `\n`

## Message Format

All messages follow a standard JSON format with a `cmd` field indicating the command type:

```json
{
  "cmd": "command_type",
  // Additional parameters specific to the command
}
```

## Commands: App → Car

### 1. Joystick Control Command

Sent when joystick position changes to control car movement.

```json
{
  "cmd": "control",
  "x": 0.75,    // Range: -1.0 to 1.0 (left to right)
  "y": -0.5     // Range: -1.0 to 1.0 (backward to forward)
}
```

**Arduino Implementation Example:**
```cpp
void handleControlCommand(JsonDocument& doc) {
  float x = doc["x"];
  float y = doc["y"];
  
  // Convert joystick values to motor speeds
  int leftMotor = calculateLeftMotorSpeed(x, y);
  int rightMotor = calculateRightMotorSpeed(x, y);
  
  // Apply motor speeds
  setMotorSpeeds(leftMotor, rightMotor);
}
```

### 2. Fire Command

Sent when user presses or releases the fire button.

```json
{
  "cmd": "fire",
  "active": true  // true when pressed, false when released
}
```

**Arduino Implementation Example:**
```cpp
void handleFireCommand(JsonDocument& doc) {
  bool isActive = doc["active"];
  
  if (isActive) {
    // Activate laser
    digitalWrite(LASER_PIN, HIGH);
    // Optional: Start a timer to automatically turn off after X ms
    startLaserTimer();
  } else {
    // Deactivate laser
    digitalWrite(LASER_PIN, LOW);
  }
}
```

### 3. Brake Command

Sent when user presses or releases the brake button.

```json
{
  "cmd": "brake",
  "active": true  // true when pressed, false when released
}
```

**Arduino Implementation Example:**
```cpp
void handleBrakeCommand(JsonDocument& doc) {
  bool isActive = doc["active"];
  
  if (isActive) {
    // Stop all motors
    stopAllMotors();
    // Optional: Visual indication of braking
    digitalWrite(BRAKE_LIGHT_PIN, HIGH);
  } else {
    // Return to normal operation
    digitalWrite(BRAKE_LIGHT_PIN, LOW);
    // Note: Motor control will resume with next control command
  }
}
```

### 4. Game Start Command

Sent when a new game is started.

```json
{
  "cmd": "gameStart",
  "mode": "Time",     // "Time" or "Points"
  "value": 5,         // Minutes for Time mode, target points for Points mode
  "player": "Alex"    // Player name
}
```

**Arduino Implementation Example:**
```cpp
void handleGameStartCommand(JsonDocument& doc) {
  String mode = doc["mode"];
  int value = doc["value"];
  String playerName = doc["player"];
  
  // Reset game state
  resetGameState();
  
  // Configure game parameters
  gameMode = mode;
  gameValue = value;
  
  // Visual/audio indication that game is starting
  playStartupSequence();
  
  // Activate IR hit detection
  enableHitDetection();
}
```

### 5. Game End Command

Sent when game concludes.

```json
{
  "cmd": "gameEnd"
}
```

**Arduino Implementation Example:**
```cpp
void handleGameEndCommand(JsonDocument& doc) {
  // Stop all motors
  stopAllMotors();
  
  // Deactivate systems
  digitalWrite(LASER_PIN, LOW);
  disableHitDetection();
  
  // Visual/audio indication that game is over
  playEndSequence();
}
```

## Commands: Car → App

### 1. Hit Detection

Sent when the car registers being hit by an opponent's laser.

```json
{
  "cmd": "hit",
  "target": "Car1"  // "Car1" or "Car2" depending on which car was hit
}
```

**Arduino Implementation Example:**
```cpp
void detectAndSendHit() {
  // Check if IR receiver has detected a valid hit signal
  if (irReceiver.decode()) {
    if (isValidHitCode(irReceiver.decodedIRData.decodedRawData)) {
      // Construct hit message
      StaticJsonDocument<64> doc;
      doc["cmd"] = "hit";
      doc["target"] = "Car1";  // Use your car's ID here
      
      // Convert to string and send
      String jsonString;
      serializeJson(doc, jsonString);
      Serial.println(jsonString);
      
      // Visual/audio feedback for being hit
      playHitIndicator();
      
      // Implement cooldown period to prevent rapid hit spamming
      delay(hitCooldownMs);
    }
    irReceiver.resume(); // Prepare for next value
  }
}
```



**Arduino Implementation Example:**
```cpp
void sendStatusUpdate() {
  // Only send periodically (e.g., every 2 seconds)
  static unsigned long lastUpdate = 0;
  if (millis() - lastUpdate < 2000) return;
  lastUpdate = millis();
  
  // Read sensor values
  float batteryLevel = readBatteryLevel();
  float currentSpeed = getCurrentSpeed();
  float temperature = readTemperature();
  
  // Construct status message
  StaticJsonDocument<128> doc;
  doc["cmd"] = "status";
  doc["battery"] = batteryLevel;
  doc["speed"] = currentSpeed;
  doc["temp"] = temperature;
  
  // Convert to string and send
  String jsonString;
  serializeJson(doc, jsonString);
  Serial.println(jsonString);
}
```

## Message Flow Examples

### Example 1: Starting a Game and Controlling the Car

1. **App sends game start:**
   ```json
   {"cmd":"gameStart","mode":"Time","value":3,"player":"Player 1"}
   ```

2. **Arduino acknowledges** (optional)

3. **App sends control commands:**
   ```json
   {"cmd":"control","x":0.0,"y":0.5}
   {"cmd":"control","x":0.2,"y":0.7}
   {"cmd":"control","x":0.0,"y":0.0}
   ```

4. **Player fires laser:**
   ```json
   {"cmd":"fire","active":true}
   {"cmd":"fire","active":false}
   ```

5. **Car detects hit and notifies app:**
   ```json
   {"cmd":"hit","target":"Car1"}
   ```

6. **Game ends:**
   ```json
   {"cmd":"gameEnd"}
   ```

### Example 2: Points-based Game Flow

1. **App sends game start:**
   ```json
   {"cmd":"gameStart","mode":"Points","value":5,"player":"Player 2"}
   ```

2. **Gameplay commands...**

3. **Car reports multiple hits during game:**
   ```json
   {"cmd":"hit","target":"Car2"}
   // Some time later
   {"cmd":"hit","target":"Car2"}
   ```

4. **Game ends automatically after a player reaches 5 points**

## Implementation Notes for Arduino

1. **JSON Parsing**
   - Use ArduinoJson library (recommend v6 or newer)
   - Allocate appropriate buffer size based on expected message size

2. **Message Reception**
   - Implement line buffering to receive complete JSON messages
   - Always validate JSON before attempting to process
   
3. **Hit Detection**
   - Use IR receiver module (e.g., TSOP38238) to detect laser hits
   - Send hit notifications immediately when detected
   - Implement cooldown period to prevent hit spamming
   
4. **Error Handling**
   - Implement watchdog timer to recover from crashes
   - Include error checking for all commands

## Arduino Core Loop Example

```cpp
void loop() {
  // Check for incoming messages from app
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    processIncomingMessage(input);
  }
  
  // Check for hit detection
  detectAndSendHit();
  
  // Regular status updates
  sendStatusUpdate();
  
  // Other car functions
  // ...
}

void processIncomingMessage(String message) {
  // Parse JSON
  StaticJsonDocument<256> doc;
  DeserializationError error = deserializeJson(doc, message);
  
  // Check for parsing errors
  if (error) {
    Serial.print("JSON parsing error: ");
    Serial.println(error.c_str());
    return;
  }
  
  // Process based on command type
  String cmd = doc["cmd"];
  
  if (cmd == "control") {
    handleControlCommand(doc);
  } 
  else if (cmd == "fire") {
    handleFireCommand(doc);
  } 
  else if (cmd == "brake") {
    handleBrakeCommand(doc);
  } 
  else if (cmd == "gameStart") {
    handleGameStartCommand(doc);
  } 
  else if (cmd == "gameEnd") {
    handleGameEndCommand(doc);
  }
}
```

## Required Arduino Libraries

1. ArduinoJson - For JSON parsing
2. IRremote - For IR communication
3. SoftwareSerial - For Bluetooth communication (if not using built-in hardware serial)

## Hardware Requirements

- Bluetooth module (HC-05 or HC-06 recommended)
- IR receiver module (e.g., TSOP38238)
- IR LED for laser/hit detection
- Motor drivers suitable for your motors
- Appropriate power supply

## Troubleshooting

1. If messages aren't being received, check:
   - Bluetooth connection status
   - Baud rate matching between app and Arduino
   - Message format and line endings

2. If hit detection isn't working:
   - Verify IR receiver is functioning
   - Check IR codes being used
   - Ensure there's no interference from ambient light
