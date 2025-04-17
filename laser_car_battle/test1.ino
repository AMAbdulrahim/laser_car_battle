// #include <Servo.h>
// #include <ArduinoJson.h>

// Servo myservo;

// const int servoPin = 9;
// StaticJsonDocument<200> doc;

// void setup() {
//   Serial.begin(9600);
//   myservo.attach(servoPin);
//   myservo.write(90); // Start centered
// }

// void loop() {
//   if (Serial.available()) {
//     String input = Serial.readStringUntil('\n');

//     DeserializationError error = deserializeJson(doc, input);
//     if (error) {
//       Serial.print("JSON parse failed: ");
//       Serial.println(error.c_str());
//       return;
//     }

//     const char* cmd = doc["cmd"];
//     if (strcmp(cmd, "control") == 0) {
//       float x = doc["x"];  // ✅ read as float!
//       float y = doc["y"];  // Optional, reserved for future

//       // ✅ map x from -1.0..1.0 → 60..120 degrees
//       int angle = (x + 1.0) * 30 + 60;
//       angle = constrain(angle, 60, 120);

//       myservo.write(angle);

//       Serial.print("x: ");
//       Serial.print(x, 2);
//       Serial.print(" → angle: ");
//       Serial.println(angle);
//     }
//   }
// }
