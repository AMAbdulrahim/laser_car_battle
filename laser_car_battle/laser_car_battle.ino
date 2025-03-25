/*
 * Laser Car Battle - Arduino ESP32 Controller
 * 
 * This code handles:
 * - BLE communication with the Flutter app
 * - Servo steering control
 * - Brushless motor control via ESC
 * - IR hit detection
 * - Laser firing
 * 
 * Hardware requirements:
 * - ESP32 development board
 * - Servo for steering
 * - ESC + Brushless motor
 * - IR receiver (for hit detection)
 * - Laser module
 * 
 * ===== SETUP INSTRUCTIONS =====
 * 
 * 1. Install Required Libraries:
 *    - Open Arduino IDE
 *    - Go to Tools > Manage Libraries
 *    - Install ArduinoJson (version 6.x)
 *    - Install ESP32Servo
 * 
 * 2. Configure the Code:
 *    - Change the DEVICE_NAME to either "Car1-YourName" or "Car2-YourName"
 *    - If needed, adjust pin assignments to match your hardware
 *    - If needed, adjust servo min/max angles based on your steering mechanism
 * 
 * 3. Upload to ESP32:
 *    - Select the correct board: Tools > Board > ESP32 > ESP32 Dev Module
 *    - Select the correct port
 *    - Click the Upload button
 * 
 * 4. Hardware Connections:
 *    ESP32 Pin 27 -> ESC signal wire
 *    ESP32 Pin 13 -> Servo signal wire
 *    ESP32 Pin 21 -> IR receiver output
 *    ESP32 Pin 22 -> Laser control (via transistor if needed)
 * 
 * 5. Testing:
 *    - Open Serial Monitor at 115200 baud to see debug messages
 *    - The device will advertise via Bluetooth as the name you configured
 *    - Connect with the Laser Car Battle app
 * 
 * ===== TROUBLESHOOTING =====
 * 
 * 1. ESC Not Responding:
 *    - Ensure ESC is properly powered
 *    - Try calibrating your ESC (refer to ESC manual)
 *    - Check if neutral position is correct (adjust ESC_ARM_SIGNAL if needed)
 * 
 * 2. Steering Issues:
 *    - Adjust SERVO_MIN_ANGLE and SERVO_MAX_ANGLE to match your steering mechanism
 *    - Ensure servo is properly powered (preferably with separate power source)
 * 
 * 3. Hit Detection Problems:
 *    - Check IR receiver orientation
 *    - Test IR reception with a TV remote
 *    - Adjust IR_DEBOUNCE value if hits are too sensitive or not registering
 * 
 * 4. Bluetooth Connection Issues:
 *    - Make sure UUIDs match exactly with the app
 *    - Reset ESP32 before trying to connect
 *    - Ensure device name starts with "Car1" or "Car2"
 */

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>

// ===== PIN CONFIGURATION =====
// Change these to match your wiring
#define MOTOR_SPEED_PIN   27   // ESC control (PWM)
#define SERVO_PIN         13   // Steering servo
#define IR_RECEIVER_PIN   21   // IR Sensor for hit detection
#define LASER_PIN         22   // Laser output

// ===== BLE CONFIGURATION =====
// Must match UUIDs in Flutter app - DO NOT CHANGE
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// ===== DEVICE IDENTITY =====
// IMPORTANT: Change this to "Car1-YourName" or "Car2-YourName"
#define DEVICE_NAME "Car1-Player1"

// ===== SERVO CONFIGURATION =====
#define SERVO_MIN_ANGLE  45    // Minimum steering angle
#define SERVO_MAX_ANGLE  135   // Maximum steering angle
#define SERVO_CENTER     90    // Center position

// ===== ESC (BRUSHLESS MOTOR) CONFIGURATION =====
#define ESC_MIN_SIGNAL    1000 // Minimum ESC signal (stopped)
#define ESC_MAX_SIGNAL    2000 // Maximum ESC signal (full speed)
#define ESC_ARM_SIGNAL    1500 // Neutral position signal

// ===== GAME VARIABLES =====
bool deviceConnected = false;
bool previouslyConnected = false;

// ===== HARDWARE OBJECTS =====
Servo steeringServo;
Servo escMotor;

// ===== BLE SERVER COMPONENTS =====
BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;

// ===== IR DECODING =====
unsigned long lastIRTime = 0;
const unsigned long IR_DEBOUNCE = 100; // Debounce time in ms

// ===== BLE SERVER CALLBACKS =====
class MyServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    Serial.println("Device connected");
  }

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    Serial.println("Device disconnected");
    
    // Restart advertising when disconnected to allow reconnection
    delay(500);
    pServer->startAdvertising();
    Serial.println("Restarting advertising");
    
    // Safety: stop motors when disconnected
    stopMotor();
    centerSteering();
  }
};

// ===== BLE CHARACTERISTIC CALLBACKS =====
class MyCharacteristicCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    std::string value = pCharacteristic->getValue();
    
    if (value.length() > 0) {
      Serial.print("Received: ");
      Serial.println(value.c_str());
      
      // Parse JSON
      StaticJsonDocument<200> doc;
      DeserializationError error = deserializeJson(doc, value.c_str());
      
      if (!error) {
        const char* cmd = doc["cmd"];
        
        // Handle different commands
        if (strcmp(cmd, "control") == 0) {
          float x = doc["x"]; // Steering: -1.0 (left) to 1.0 (right)
          float y = doc["y"]; // Throttle: -1.0 (backward) to 1.0 (forward)
          handleMovement(x, y);
          
        } else if (strcmp(cmd, "fire") == 0) {
          bool active = doc["active"];
          handleFire(active);
          
        } else if (strcmp(cmd, "brake") == 0) {
          bool active = doc["active"];
          handleBrake(active);
          
        } else if (strcmp(cmd, "gameStart") == 0) {
          // Just acknowledge game start - actual logic is in app
          Serial.println("Game started");
          
        } else if (strcmp(cmd, "gameEnd") == 0) {
          // Just stop everything on game end
          stopMotor();
          centerSteering();
          digitalWrite(LASER_PIN, LOW);
        }
      } else {
        Serial.print("JSON error: ");
        Serial.println(error.c_str());
      }
    }
  }
};

void setup() {
  // Initialize serial for debugging
  Serial.begin(115200);
  Serial.println("\n=== Laser Car Battle Starting ===");
  Serial.print("Device name: ");
  Serial.println(DEVICE_NAME);
  
  // Configure pins
  pinMode(IR_RECEIVER_PIN, INPUT);
  pinMode(LASER_PIN, OUTPUT);
  digitalWrite(LASER_PIN, LOW);
  
  // Initialize servo and ESC
  ESP32PWM::allocateTimer(0);
  ESP32PWM::allocateTimer(1);
  steeringServo.setPeriodHertz(50);    // Standard 50Hz servo
  steeringServo.attach(SERVO_PIN, 500, 2500);  // Attach with min/max pulse width
  
  escMotor.setPeriodHertz(50);         // Standard 50Hz for ESC
  escMotor.attach(MOTOR_SPEED_PIN, ESC_MIN_SIGNAL, ESC_MAX_SIGNAL);
  
  // Initial positions
  centerSteering();
  armESC();
  
  // Initialize BLE
  initBLE();
  
  Serial.println("Setup complete, ready to connect");
}

void loop() {
  // Check for IR hits
  checkForHit();
  
  // Manage connection state
  if (deviceConnected && !previouslyConnected) {
    // Just connected
    previouslyConnected = true;
    Serial.println("Connected to app");
  }
  
  if (!deviceConnected && previouslyConnected) {
    // Just disconnected
    previouslyConnected = false;
    Serial.println("Disconnected from app");
    stopMotor(); // Safety stop
    centerSteering();
  }
  
  delay(10); // Small delay to avoid CPU hogging
}

// Initialize BLE server and services
void initBLE() {
  // Create the BLE Device
  BLEDevice::init(DEVICE_NAME);
  
  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  
  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);
  
  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  
  // Create BLE Descriptor
  pCharacteristic->addDescriptor(new BLE2902());
  pCharacteristic->setCallbacks(new MyCharacteristicCallbacks());
  
  // Start the service
  pService->start();
  
  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  
  Serial.println("BLE initialized, advertising started");
}

// Initialize the ESC
void armESC() {
  Serial.println("Arming ESC...");
  escMotor.writeMicroseconds(ESC_ARM_SIGNAL);
  delay(2000);  // Give time for ESC to initialize
  Serial.println("ESC armed");
}

// Center the steering servo
void centerSteering() {
  steeringServo.write(SERVO_CENTER);
}

// Handle joystick movement commands
void handleMovement(float x, float y) {
  // Debug output
  Serial.print("Move: x=");
  Serial.print(x);
  Serial.print(", y=");
  Serial.println(y);
  
  // Convert x (-1 to 1) to servo angle
  int servoAngle = map(x * 100, -100, 100, SERVO_MIN_ANGLE, SERVO_MAX_ANGLE);
  steeringServo.write(servoAngle);
  
  // Convert y (-1 to 1) to motor speed
  setMotorSpeed(y);
}

// Set motor speed based on y value (-1 to 1)
void setMotorSpeed(float y) {
  int signal;
  
  if (abs(y) < 0.1) {
    // Dead zone around center
    signal = ESC_ARM_SIGNAL;
  } else {
    // Convert y (-1 to 1) to ESC signal
    signal = map(y * 100, -100, 100, ESC_MIN_SIGNAL, ESC_MAX_SIGNAL);
  }
  
  // Apply the signal to the ESC
  escMotor.writeMicroseconds(signal);
  Serial.print("Motor signal: ");
  Serial.println(signal);
}

// Stop the motor
void stopMotor() {
  escMotor.writeMicroseconds(ESC_ARM_SIGNAL);
  Serial.println("Motor stopped");
}

// Handle fire button
void handleFire(bool active) {
  digitalWrite(LASER_PIN, active ? HIGH : LOW);
  Serial.print("Laser: ");
  Serial.println(active ? "ON" : "OFF");
}

// Handle brake button
void handleBrake(bool active) {
  if (active) {
    stopMotor();
    Serial.println("Brake applied");
  }
  // When brake released, do nothing (wait for next movement command)
}

// Check IR sensor for hit detection
void checkForHit() {
  // Simple IR detection (low = detected beam, high = no beam)
  if (digitalRead(IR_RECEIVER_PIN) == LOW) {
    unsigned long currentTime = millis();
    
    // Debounce hits
    if (currentTime - lastIRTime > IR_DEBOUNCE) {
      lastIRTime = currentTime;
      
      Serial.println("IR BEAM DETECTED - HIT!");
      onHitDetected();
    }
  }
}

// Process and notify when car is hit
void onHitDetected() {
  // Send hit message to app
  if (deviceConnected) {
    // Create JSON message
    StaticJsonDocument<100> doc;
    doc["cmd"] = "hit";
    doc["carId"] = DEVICE_NAME;
    
    char buffer[100];
    serializeJson(doc, buffer);
    
    // Send via BLE
    pCharacteristic->setValue(buffer);
    pCharacteristic->notify();
    Serial.println("Hit notification sent to app");
  }
}