// /*
//  * Laser Car Battle - Arduino ESP32 Controller
//  *
//  * See setup instructions in original comment block.
//  */

// #include <Arduino.h>
// #include <BLEDevice.h>
// #include <BLEServer.h>
// #include <BLEUtils.h>
// #include <BLE2902.h>
// #include <ArduinoJson.h>
// #include <ESP32Servo.h>

// // ===== PIN CONFIGURATION =====
// #define MOTOR_SPEED_PIN   27
// #define SERVO_PIN         13
// #define IR_RECEIVER_PIN   21
// #define LASER_PIN         22

// // ===== BLE CONFIGURATION =====
// #define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
// #define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
// #define DEVICE_NAME         "Car1-Player1"

// // ===== SERVO CONFIGURATION =====
// #define SERVO_MIN_ANGLE  45
// #define SERVO_MAX_ANGLE  135
// #define SERVO_CENTER     90

// // ===== ESC CONFIGURATION =====
// #define ESC_MIN_SIGNAL    1000
// #define ESC_MAX_SIGNAL    2000
// #define ESC_ARM_SIGNAL    1500

// // ===== GAME VARIABLES =====
// bool deviceConnected = false;
// bool previouslyConnected = false;

// Servo steeringServo;
// Servo escMotor;
// BLEServer* pServer = NULL;
// BLECharacteristic* pCharacteristic = NULL;

// unsigned long lastIRTime = 0;
// const unsigned long IR_DEBOUNCE = 100;

// // ===== BLE SERVER CALLBACKS =====
// class MyServerCallbacks: public BLEServerCallbacks {
//   void onConnect(BLEServer* pServer) {
//     deviceConnected = true;
//     Serial.println("Device connected");
//   }

//   void onDisconnect(BLEServer* pServer) {
//     deviceConnected = false;
//     Serial.println("Device disconnected");
//     delay(500);
//     pServer->startAdvertising();
//     Serial.println("Restarting advertising");
//     // stopMotor();
//     // centerSteering();
//   }
// };

// // ===== BLE CHARACTERISTIC CALLBACKS =====
// class MyCharacteristicCallbacks: public BLECharacteristicCallbacks {
//   void onWrite(BLECharacteristic* pCharacteristic) {
//     String value = pCharacteristic->getValue().c_str();

//     if (value.length() > 0) {
//       Serial.print("Received: ");
//       Serial.println(value);

//       StaticJsonDocument<200> doc;
//       DeserializationError error = deserializeJson(doc, value);

//       if (!error) {
//         const char* cmd = doc["cmd"];

//         if (strcmp(cmd, "control") == 0) {
//           float x = doc["x"];
//           float y = doc["y"];
//           // handleMovement(x, y);

//         } else if (strcmp(cmd, "fire") == 0) {
//           bool active = doc["active"];
//           // handleFire(active);

//         } else if (strcmp(cmd, "brake") == 0) {
//           bool active = doc["active"];
//           // handleBrake(active);

//         } else if (strcmp(cmd, "gameStart") == 0) {
//           Serial.println("Game started");

//         } else if (strcmp(cmd, "gameEnd") == 0) {
//           // stopMotor();
//           // centerSteering();
//           digitalWrite(LASER_PIN, LOW);
//         }
//       } else {
//         Serial.print("JSON error: ");
//         Serial.println(error.c_str());
//       }
//     }
//   }
// };

// void setup() {
//   Serial.begin(115200);
//   Serial.println("\n=== Laser Car Battle Starting ===");
//   Serial.print("Device name: ");
//   Serial.println(DEVICE_NAME);

//   pinMode(IR_RECEIVER_PIN, INPUT);
//   pinMode(LASER_PIN, OUTPUT);
//   digitalWrite(LASER_PIN, LOW);

//   ESP32PWM::allocateTimer(0);
//   ESP32PWM::allocateTimer(1);

//   steeringServo.setPeriodHertz(50);
//   steeringServo.attach(SERVO_PIN, 500, 2500);

//   escMotor.setPeriodHertz(50);
//   escMotor.attach(MOTOR_SPEED_PIN, ESC_MIN_SIGNAL, ESC_MAX_SIGNAL);

//   // centerSteering();
//   // armESC();
//   initBLE();

//   Serial.println("Setup complete, ready to connect");
// }

// void loop() {
//   // checkForHit(); // Uncomment to enable IR hit detection

//   if (deviceConnected && !previouslyConnected) {
//     previouslyConnected = true;
//     Serial.println("Connected to app");
//   }

//   if (!deviceConnected && previouslyConnected) {
//     previouslyConnected = false;
//     Serial.println("Disconnected from app");
//     // stopMotor();
//     // centerSteering();
//   }

//   delay(10);
// }

// void initBLE() {
//   BLEDevice::init(DEVICE_NAME);
//   pServer = BLEDevice::createServer();
//   pServer->setCallbacks(new MyServerCallbacks());

//   BLEService *pService = pServer->createService(SERVICE_UUID);
//   pCharacteristic = pService->createCharacteristic(
//                       CHARACTERISTIC_UUID,
//                       BLECharacteristic::PROPERTY_READ |
//                       BLECharacteristic::PROPERTY_WRITE |
//                       BLECharacteristic::PROPERTY_NOTIFY);

//   pCharacteristic->addDescriptor(new BLE2902());
//   pCharacteristic->setCallbacks(new MyCharacteristicCallbacks());
//   pService->start();

//   BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
//   pAdvertising->addServiceUUID(SERVICE_UUID);
//   pAdvertising->setScanResponse(true);
//   pAdvertising->setMinPreferred(0x06);
//   pAdvertising->setMinPreferred(0x12);
//   BLEDevice::startAdvertising();

//   Serial.println("BLE initialized, advertising started");
// }

// void armESC() {
//   Serial.println("Arming ESC...");
//   escMotor.writeMicroseconds(ESC_ARM_SIGNAL);
//   delay(2000);
//   Serial.println("ESC armed");
// }

// void centerSteering() {
//   steeringServo.write(SERVO_CENTER);
// }

// void handleMovement(float x, float y) {
//   Serial.print("Move: x="); Serial.print(x);
//   Serial.print(", y="); Serial.println(y);

//   int servoAngle = map(x * 100, -100, 100, SERVO_MIN_ANGLE, SERVO_MAX_ANGLE);
//   steeringServo.write(servoAngle);
//   setMotorSpeed(y);
// }

// void setMotorSpeed(float y) {
//   int signal = (abs(y) < 0.1) ? ESC_ARM_SIGNAL : map(y * 100, -100, 100, ESC_MIN_SIGNAL, ESC_MAX_SIGNAL);
//   escMotor.writeMicroseconds(signal);
//   Serial.print("Motor signal: "); Serial.println(signal);
// }

// void stopMotor() {
//   escMotor.writeMicroseconds(ESC_ARM_SIGNAL);
//   Serial.println("Motor stopped");
// }

// void handleFire(bool active) {
//   digitalWrite(LASER_PIN, active ? HIGH : LOW);
//   Serial.print("Laser: "); Serial.println(active ? "ON" : "OFF");
// }

// void handleBrake(bool active) {
//   if (active) {
//     stopMotor();
//     Serial.println("Brake applied");
//   }
// }

// void checkForHit() {
//   if (digitalRead(IR_RECEIVER_PIN) == LOW) {
//     unsigned long currentTime = millis();
//     if (currentTime - lastIRTime > IR_DEBOUNCE) {
//       lastIRTime = currentTime;
//       Serial.println("IR BEAM DETECTED - HIT!");
//       onHitDetected();
//     }
//   }
// }

// void onHitDetected() {
//   if (deviceConnected) {
//     StaticJsonDocument<100> doc;
//     doc["cmd"] = "hit";
//     doc["carId"] = DEVICE_NAME;

//     char buffer[100];
//     serializeJson(doc, buffer);
//     pCharacteristic->setValue(buffer);
//     pCharacteristic->notify();
//     Serial.println("Hit notification sent to app");
//   }
// }
