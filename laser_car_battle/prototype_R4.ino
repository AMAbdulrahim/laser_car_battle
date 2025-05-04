#include <SoftwareSerial.h>
#include <Servo.h>
#include <ArduinoJson.h>

Servo esc;       // Brushless ESC
Servo myservo;   // Servo motor

SoftwareSerial hc05(0, 1);  // RX, TX

String inputString = "";
bool stringComplete = false;
bool servoAttached = true;

void setup() {
  Serial.begin(9600);
  hc05.begin(9600);

  esc.attach(10);         // ESC on pin 10
  myservo.attach(9);      // Servo on pin 9
  pinMode(11, OUTPUT);
  digitalWrite(11, LOW);
  // Arm ESC
  esc.writeMicroseconds(1000);
  delay(2000);
  Serial.println("ESC Armed. Ready for JSON input.");

  inputString.reserve(128); // Reserve memory for input
}

void loop() {
  // Read from HC-05
  while (hc05.available()) {
    char inChar = (char)hc05.read();
    if (inChar == '\n') {
      stringComplete = true;
      break;
    } else {
      inputString += inChar;
    }
  }

  if (stringComplete) {
    processJson(inputString);
    inputString = "";
    stringComplete = false;
  }

  // Echo Serial input to HC-05 (optional)
  if (Serial.available()) {
    hc05.write(Serial.read());
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
    return;
  }

  const char* cmd = doc["cmd"];
  if (cmd == "fire") {
      digitalWrite(11, HIGH);
  }else{
      digitalWrite(11, LOW);
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
  if (y <-0.5){
    y = -1;
  }

  if (y > 0) {
    throttle = mapFloat(y, 0, 1, 1600, 2000); // Dead zone
  } else if (abs(y) > 0.5) {
    throttle = 1000; // Forward
  } else {
    throttle = 1500; // Reverse
  }
  Serial.println(y);
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
