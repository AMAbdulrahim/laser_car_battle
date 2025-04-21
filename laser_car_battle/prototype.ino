#include <Servo.h>
#include <ArduinoJson.h>

Servo esc;       // Brushless ESC
Servo myservo;   // Servo motor

String inputString = "";
bool stringComplete = false;
int pos = 90;
bool servoAttached = true;

void setup() {
  Serial.begin(9600);

  esc.attach(10);         // ESC on pin 10
  myservo.attach(9);      // Servo on pin 9
  pinMode(13, OUTPUT);

  // Arm ESC
  esc.writeMicroseconds(1000);
  delay(2000);
  Serial.println("ESC Armed. Ready for JSON input.");

  inputString.reserve(128); // Reserve enough space for JSON input
}

void loop() {
  if (stringComplete) {
    processJson(inputString);
    inputString = "";
    stringComplete = false;
  }
}

void serialEvent() {
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    if (inChar == '\n') {
      stringComplete = true;
    } else {
      inputString += inChar;
    }
  }
}

void processJson(String input) {
  input.trim();
  Serial.print("Received JSON: ");
  Serial.println(input);

  StaticJsonDocument<128> doc;
  DeserializationError error = deserializeJson(doc, input);

  if (error) {
    Serial.print("JSON Parse Error: ");
    Serial.println(error.c_str());
    int throttle = 1500;
    return;
  }

  const char* cmd = doc["cmd"];
  if (strcmp(cmd, "control") != 0) {
    Serial.println("Invalid or missing command.");
    return;
  }

  float x = doc["x"].as<float>(); // -1 to 1
  float y = doc["y"].as<float>(); // -1 to 1

if (fabs(y) < 0.05) {
  y = 0.0;
}
  Serial.print("Parsed x: "); Serial.println(x);
  Serial.print("Parsed y: "); Serial.println(y);

  // --- Servo Control ---
  x = constrain(x, -1.0, 1.0);
  int angle = mapFloat(x, -1.0, 1.0, 60, 120);
  attachServoIfNeeded();
  myservo.write(angle);
  Serial.print("Servo angle: ");
  Serial.println(angle);

  // --- ESC Control ---
  y = constrain(y, -1.0, 1.0);
  int throttle = 1500;

  if (abs(y) < 0.05) {
    throttle = 1500; // Dead zone
  } else if (y > 0) {
    throttle = mapFloat(y, 0.05, 1.0, 1600, 2000); // Forward
  } else {
    throttle = mapFloat(abs(y), 0.05, 1.0, 1400, 1000); // Reverse
  }

  esc.writeMicroseconds(throttle);
  Serial.print("ESC throttle set to: ");
  Serial.println(throttle);
}

int mapFloat(float x, float in_min, float in_max, int out_min, int out_max) {
  return (int)(out_min + (x - in_min) * (out_max - out_min) / (in_max - in_min));
}

// Servo utilities
void stopServo() {
  if (servoAttached) {
    myservo.detach();
    servoAttached = false;
    Serial.println("Servo stopped");
  }
}

void attachServoIfNeeded() {
  if (!servoAttached) {
    myservo.attach(9);
    servoAttached = true;
    Serial.println("Servo reattached");
  }
}
