// #include <Servo.h>

// char Incoming_value = 0;
// Servo myservo;
// int pos = 0;

// void setup() {
//   Serial.begin(9600);
//   myservo.attach(9);        
//   pinMode(13, OUTPUT);       
// }

// void loop() {
//   delay(5);
//   if (Serial.available() > 0) {
//     Incoming_value = Serial.read();      

//     if (Incoming_value == 'R' || Incoming_value == 'L') {
//       Serial.print("Received: ");
//       Serial.println(Incoming_value);

//       if (Incoming_value == 'R'){             
//         myservo.attach(9);        
//         right();   
//       }else if (Incoming_value == 'L'){
//         myservo.attach(9);       
//         left();  
//       }else if (Incoming_value == 'S')
//         stop();
//     }
//   }                            
// }

// void right() {
//   pos = max(pos - 30, 0);``
//   Serial.print("pos: ");
//   Serial.println(pos);
//   myservo.write(pos);
// }

// void left() {
//   pos = min(180, pos + 30);
//   Serial.print("pos: ");
//   Serial.println(pos);
//   myservo.write(pos);
// }

// void stop() {
//   myservo.detach(); // Detach the servo to stop it immediately
//   Serial.println("Servo stopped");
// }
