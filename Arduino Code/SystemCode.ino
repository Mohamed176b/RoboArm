#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
#include <SoftwareSerial.h>
#include <LiquidCrystal_I2C.h>

// Define the PCA9685 PWM Servo Driver
SoftwareSerial Bluetooth(10, 11); 
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
LiquidCrystal_I2C lcd(0x27, 20, 4); // Set the LCD I2C address to 0x27 for a 20x2 display

// Define the servos
/*
// Define the buttons
const int button1 = 22; // save movant 
const int button2 = 23; // clear/reset movant 
const int playButton = 27; // New play button*/
const int stopButton = 24; // New stop button
const int move1 = 25;
const int move2 = 26;

const int startSensorPin = 2;  // Digital pin for the "Start" IR sensor
const int stopSensorPin = 3;   // Digital pin for the "Stop" IR sensor
const int motorPin1 = 4;       // Motor control pin 1
const int motorPin2 = 5;       // Motor control pin 2
const int enablePin = 6 ; // Connect to enable pin (ENA) of L298N


// Define variables 
int button1Pressed = 0;  // counter for saved positions 
bool button2Pressed = false; // Flag for the play button
bool stopButtonPressed = false; // Flag for the stop button
bool move1Pressed = false; // Flag for the move1 button
bool move2Pressed = false; // Flag for the move2 button
bool startSensorState; //Flag for "Start" IR sensor
bool stopSensorState; //Flag for "Stop" IR sensor
bool initialMoveDone = false; // Flag to track whether the initial movement has been completed
bool PotentiometerMode = true;
int savedPositionCount = 0; // Define a counter for saved positions
String dataIn = "";  // to control each servo 
int speedDelay = 20;
int speedDelayMotor = 10;
// Servo parameters
#define SERVOMIN  125 // Minimum pulse length
#define SERVOMAX  575 // Maximum pulse length

// Define JoySticks
int joystick_x1 = A0;
int joystick_y1 = A1;
int joystick_x2 = A2;
int joystick_y2 = A3;
int joystick_x3 = A6;
int joystick_y3 = A7;

// Define variables for angles of the JoySticks
int x1_axis_degree =121;
int y1_axis_degree =90 ;
int x2_axis_degree =56 ;
int y2_axis_degree =173;
int x3_axis_degree =10 ;
int y3_axis_degree =120 ;

// Define speed control variables for each servo
int x1_speed = 4;
int y1_speed = 4;
int x2_speed = 4;
int y2_speed = 6;
int x3_speed = 6;
int y3_speed = 6;

// Define arrays to store servo positions
int servo01SP[2]; 
int servo02SP[2];
int servo03SP[2];
int servo04SP[2];
int servo05SP[2];
int servo06SP[2];

// Define arrays to store servo positions move 1
int servo01M1[2]={119,195}; 
int servo02M1[2]={94,94};
int servo03M1[2]={42,70};
int servo04M1[2]={149,149};
int servo05M1[2]={10,10};
int servo06M1[2]={179,120};

// Define arrays to store servo positions move 2
int servo01M2[2]={119,199}; 
int servo02M2[2]={94,94};
int servo03M2[2]={42,70};
int servo04M2[2]={149,149};
int servo05M2[2]={10,10};
int servo06M2[2]={179,120};

// Function to convert angle to pulse width
uint16_t angleToPulse(uint16_t angle) {
  return map(angle, 0, 180, SERVOMIN, SERVOMAX);
}

// function to control with servos via Joystick
void PotentiometerModeF (){
	int joystick_x_value1 = analogRead(joystick_x1);
  int joystick_y_value1 = analogRead(joystick_y1);
  int joystick_x_value2 = analogRead(joystick_x2);
  int joystick_y_value2 = analogRead(joystick_y2);
  int joystick_x_value3 = analogRead(joystick_x3);
  int joystick_y_value3 = analogRead(joystick_y3);

  // Update servo positions with speed control, preventing simultaneous movement
  if (abs(joystick_x_value1 - 512) > abs(joystick_y_value1 - 512)) {
    x1_axis_degree = min(237, max(65, x1_axis_degree + (joystick_x_value1 < 340 ? -x1_speed : (joystick_x_value1 > 680 ? x1_speed : 0))));
  } else {
    y1_axis_degree = min(150, max(90, y1_axis_degree + (joystick_y_value1 < 340 ? -y1_speed : (joystick_y_value1 > 680 ? y1_speed : 0))));
  }

  if (abs(joystick_x_value2 - 512) > abs(joystick_y_value2 - 512)) {
    x2_axis_degree = min(90, max(0, x2_axis_degree + (joystick_x_value2 < 340 ? x2_speed : (joystick_x_value2 > 680 ? -x2_speed : 0))));
  } else {
    y2_axis_degree = min(179, max(90, y2_axis_degree + (joystick_y_value2 < 340 ? y2_speed : (joystick_y_value2 > 680 ? -y2_speed : 0))));
  }

  if (abs(joystick_x_value3 - 512) > abs(joystick_y_value3 - 512)) {
    x3_axis_degree = min(179, max(0, x3_axis_degree + (joystick_x_value3 < 340 ? -x3_speed : (joystick_x_value3 > 680 ? x3_speed : 0))));
  } else {
    y3_axis_degree = min(179, max(120, y3_axis_degree + (joystick_y_value3 < 340 ? y3_speed : (joystick_y_value3 > 680 ? -y3_speed : 0))));
  }
  // Set servo positions
  pwm.setPWM(15, 0, angleToPulse(x1_axis_degree));
  pwm.setPWM(14, 0, angleToPulse(y1_axis_degree));
  pwm.setPWM(13, 0, angleToPulse(x2_axis_degree));
  pwm.setPWM(12, 0, angleToPulse(y2_axis_degree));
  pwm.setPWM(11, 0, angleToPulse(x3_axis_degree));
  pwm.setPWM(10, 0, angleToPulse(y3_axis_degree));

  delay(10); // Increase delay to slow down servo movement
}

// function to save position
void savePosition(int save1 , int save2 , int save3 , int save4 ,int save5 ,int save6) {
  if (savedPositionCount < 2) { // Check if there is space in the array
    servo01SP[savedPositionCount] = save1;
    servo02SP[savedPositionCount] = save2;
    servo03SP[savedPositionCount] = save3;
    servo04SP[savedPositionCount] = save4;
    servo05SP[savedPositionCount] = save5;
    servo06SP[savedPositionCount] = save6;
    savedPositionCount++; // Increment the counter
    if (savedPositionCount == 1)
    {
      lcd.clear();
      lcd.setCursor(8, 0);
      lcd.print("NCTU");
      lcd.setCursor(3, 1);
      lcd.print("ICT department");
      lcd.setCursor(3, 2);
      lcd.print("RoboArm control");
      lcd.setCursor(0, 3);
      lcd.print("Start angle saved");
      Bluetooth.println("Start angle saved");
      Bluetooth.print("Servo 1 start angle: ");
      Bluetooth.println(save1);
      Bluetooth.print("Servo 2 start angle: ");
      Bluetooth.println(save2);
      Bluetooth.print("Servo 3 start angle: ");
      Bluetooth.println(save3);
      Bluetooth.print("Servo 4 start angle: ");
      Bluetooth.println(save4);
      Bluetooth.print("Servo 5 start angle: ");
      Bluetooth.println(save5);
      Bluetooth.print("Servo 6 start angle: ");
      Bluetooth.println(save6);
    }
    else if(savedPositionCount == 2)
    {
      lcd.clear();
      lcd.setCursor(8, 0);
      lcd.print("NCTU");
      lcd.setCursor(3, 1);
      lcd.print("ICT department");
      lcd.setCursor(3, 2);
      lcd.print("RoboArm control");
      lcd.setCursor(0, 3);
      lcd.print("End angle saved");
      Bluetooth.println("End angle saved");
      Bluetooth.print("Servo 1 end angle: ");
      Bluetooth.println(save1);
      Bluetooth.print("Servo 2 end angle: ");
      Bluetooth.println(save2);
      Bluetooth.print("Servo 3 end angle: ");
      Bluetooth.println(save3);
      Bluetooth.print("Servo 4 end angle: ");
      Bluetooth.println(save4);
      Bluetooth.print("Servo 5 end angle: ");
      Bluetooth.println(save5);
      Bluetooth.print("Servo 6 end angle: ");
      Bluetooth.println(save6);
      
    }
    delay(1000);
  } else {
    lcd.clear();
    lcd.setCursor(8, 0);
    lcd.print("NCTU");
    lcd.setCursor(3, 1);
    lcd.print("ICT department");
    lcd.setCursor(3, 2);
    lcd.print("RoboArm control");
    lcd.setCursor(0, 3);
    lcd.print("No space!!");
    Bluetooth.println("No more space for saved positions.");
  }
}

// Function to reset saved positions
void resetSavedPositions() {
  memset(servo01SP, 0, sizeof(servo01SP)); // Clear the array data to 0
  memset(servo02SP, 0, sizeof(servo02SP));
  memset(servo03SP, 0, sizeof(servo03SP));
  memset(servo04SP, 0, sizeof(servo04SP));
  memset(servo05SP, 0, sizeof(servo05SP));
  memset(servo06SP, 0, sizeof(servo06SP));
  savedPositionCount = 0; // Reset the counter
  initialMoveDone = false;  // Set the flag to true after the initial move
  PotentiometerMode =true;
  lcd.clear();
  lcd.setCursor(8, 0);
  lcd.print("NCTU");
  lcd.setCursor(3, 1);
  lcd.print("ICT department");
  lcd.setCursor(3, 2);
  lcd.print("RoboArm control");
  lcd.setCursor(0, 3);
  lcd.print("Saved positions reset");
  Bluetooth.println("positions reset");
}

// Function to move servo's to their postions 
void moveServo(int servoNum ,int startPos, int endPos, int speedDelay) {
  if (startPos == endPos) return;  // Do nothing if the start position equals the end position
  if (startPos < endPos) {
    for (int pos = startPos; pos <= endPos; pos++) {
      pwm.setPWM(servoNum, 0, angleToPulse(pos));
      delay(speedDelay);
    }
  } else if (startPos > endPos) {
    for (int pos = startPos; pos >= endPos; pos--) {
      pwm.setPWM(servoNum, 0, angleToPulse(pos));
      delay(speedDelay);
    }
  }
}

void moveServosBetweenPositions(int startPos1, int endPos1,int startPos2, int endPos2,int startPos3, int endPos3,int startPos4, int endPos4,int startPos5, int endPos5,int startPos6, int endPos6) {
  if (!initialMoveDone) {
    moveServo(15, x1_axis_degree,startPos1, speedDelay);
    delay(speedDelayMotor);
    moveServo(13, x2_axis_degree, startPos3, speedDelay);
    delay(speedDelayMotor);
    moveServo(14, y1_axis_degree, startPos2, speedDelay);
    delay(speedDelayMotor);
    moveServo(12, y2_axis_degree, startPos4, speedDelay);
    delay(speedDelayMotor);
    moveServo(11, x3_axis_degree, startPos5, speedDelay);
    delay(speedDelayMotor);
    moveServo(10, y3_axis_degree, startPos6, speedDelay);
    initialMoveDone = true;  // Set the flag to true after the initial move
  }
  
  // Move servos from position 0 to position 1
  moveServo(13, startPos3, endPos3, speedDelay);
  delay(speedDelayMotor);
  moveServo(15, startPos1, endPos1, speedDelay);
  delay(speedDelayMotor);
  moveServo(14, startPos2, endPos2, speedDelay);
  delay(speedDelayMotor);
  moveServo(12, startPos4, endPos4, speedDelay);
  delay(speedDelayMotor);
  moveServo(11, startPos5, endPos5, speedDelay);
  delay(speedDelayMotor);
  moveServo(10, startPos6, endPos6, speedDelay);

  x1_axis_degree=endPos1;
  y1_axis_degree=endPos2;
  x2_axis_degree=endPos3;
  y2_axis_degree=endPos4;
  x3_axis_degree=endPos5;
  y3_axis_degree=endPos6;

  // Move servos from position 1 to position 0
 /* moveServo(13, endPos3, startPos3, speedDelay);
  delay(speedDelayMotor);
  moveServo(15, endPos1, startPos1, speedDelay);
  delay(speedDelayMotor);
  moveServo(14, endPos2, startPos2, speedDelay);
  delay(speedDelayMotor);
  moveServo(12, endPos4, startPos4, speedDelay);
  delay(speedDelayMotor);
  moveServo(11, endPos5, startPos5, speedDelay);
  delay(speedDelayMotor);
  moveServo(10, endPos6, startPos6, speedDelay);*/
}

void setup() {
  Serial.begin(9600); // Serial monitor
  Bluetooth.begin(9600); // Default baud rate of the Bluetooth module
  pwm.begin();
  pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates
  Wire.begin();
  /*
  // Define buttons as input units
  pinMode(button1, INPUT); // counter for save postions 
  pinMode(button2, INPUT); // reset button 
  pinMode(playButton, INPUT); // New play button*/
  pinMode(stopButton, INPUT); // New stop button
  pinMode(move1,INPUT);
  pinMode(move2,INPUT);
  
  pinMode(startSensorPin, INPUT);
  pinMode(stopSensorPin, INPUT);
  pinMode(motorPin1, OUTPUT);
  pinMode(motorPin2, OUTPUT);
  pinMode(enablePin, OUTPUT);
  
  // Ensure motor is off at startup
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, LOW);
  analogWrite(enablePin, 0);




  // Initialize LCD
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(8, 0);
  lcd.print("NCTU");
  lcd.setCursor(3, 1);
  lcd.print("ICT department");
  lcd.setCursor(3, 2);
  lcd.print("RoboArm control");
  lcd.setCursor(0, 3);
  lcd.print("System  is Ready");


}

void loop() {
  
    PotentiometerModeF();
  
  int motorSpeed = 210; // Adjust the speed as needed
  // Control the speed of the motor using PWM
  analogWrite(enablePin, motorSpeed);
  // Read the state of the sensors
  startSensorState = digitalRead(startSensorPin);
  stopSensorState = digitalRead(stopSensorPin);
  // Check if button1 is pressed (HIGH), save the potentiometers' position
  /*if (digitalRead(button1) == HIGH) {
    // Save positions as long as button1 is pressed
      savePosition(x1_axis_degree, y1_axis_degree, x2_axis_degree, y2_axis_degree, x3_axis_degree, y3_axis_degree);
  }

  // Check if the play button is pressed (HIGH)
  if (digitalRead(playButton) == HIGH) {
    button2Pressed = true; // Resume servo movement
  }
   // function to reset the movement 
   if (digitalRead(button2) == HIGH) {
    resetSavedPositions();
  }
  */

  // Check if the move1 button is pressed (HIGH)
  if (digitalRead(move1) == HIGH) {
    move1Pressed = true; // Resume servo movement
    PotentiometerMode =false;
    lcd.clear();
    lcd.setCursor(8, 0);
    lcd.print("NCTU");
    lcd.setCursor(3, 1);
    lcd.print("ICT department");
    lcd.setCursor(3, 2);
    lcd.print("RoboArm control");
    lcd.setCursor(0, 3);
    lcd.print("Move 1 on");
  }

  // Check if the move2 button is pressed (HIGH)
   if (digitalRead(move2) == HIGH) {
    move2Pressed = true; // Resume servo movement
    PotentiometerMode =false;
    lcd.clear();
    lcd.setCursor(8, 0);
    lcd.print("NCTU");
    lcd.setCursor(3, 1);
    lcd.print("ICT department");
    lcd.setCursor(3, 2);
    lcd.print("RoboArm control");
    lcd.setCursor(0, 3);
    lcd.print("Move 2 on");
  }
 
  // check if convert to bluetooth control
  if (Bluetooth.available() > 0) {
    char command = Bluetooth.read();
    switch (command) {
      case 'M':
        move1Pressed = true;
        PotentiometerMode =false;
        lcd.clear();
        lcd.setCursor(8, 0);
        lcd.print("NCTU");
        lcd.setCursor(3, 1);
        lcd.print("ICT department");
        lcd.setCursor(3, 2);
        lcd.print("RoboArm control");
        lcd.setCursor(0, 3);
        lcd.print("Move 1 on");
        Bluetooth.println("Move 1");
        break;
      case 'N':
        move2Pressed = true;
        PotentiometerMode =false;
        lcd.clear();
        lcd.setCursor(8, 0);
        lcd.print("NCTU");
        lcd.setCursor(3, 1);
        lcd.print("ICT department");
        lcd.setCursor(3, 2);
        lcd.print("RoboArm control");
        lcd.setCursor(0, 3);
        lcd.print("Move 2 on");
        Bluetooth.println("Move 2");
        break;
      case 'P':
        button2Pressed = true;
        PotentiometerMode =false;
        Bluetooth.println("Play mode");
        lcd.clear();
        lcd.setCursor(8, 0);
        lcd.print("NCTU");
        lcd.setCursor(3, 1);
        lcd.print("ICT department");
        lcd.setCursor(3, 2);
        lcd.print("RoboArm control");
        lcd.setCursor(0, 3);
        lcd.print("Play mode");
        break;
      case 'V':
          savePosition(x1_axis_degree, y1_axis_degree, x2_axis_degree, y2_axis_degree, x3_axis_degree, y3_axis_degree);
        break;
      case 'R':
        resetSavedPositions();
        break;
    }
  }
  // Functio to play the custom move
  if (button2Pressed) {
    if ( savedPositionCount == 0)
    {
      Bluetooth.println("save some positiones");
      button2Pressed = false;
      PotentiometerMode =true;
      lcd.clear();
      lcd.setCursor(8, 0);
      lcd.print("NCTU");
      lcd.setCursor(3, 1);
      lcd.print("ICT department");
      lcd.setCursor(3, 2);
      lcd.print("RoboArm control");
      lcd.setCursor(0, 3);
      lcd.print("save some positiones");
    }
    else{
    // Motor control logic
    if (!startSensorState || !stopSensorState || startSensorState || stopSensorState) {
    // Start sensor is HIGH
    if(!startSensorState && stopSensorState)
    {
      digitalWrite(motorPin1, HIGH); // Set motor direction forward
      digitalWrite(motorPin2, LOW);
      
    }
    else if (!startSensorState && !stopSensorState || startSensorState && !stopSensorState){
      digitalWrite(motorPin1, LOW); // Set motor direction forward
      digitalWrite(motorPin2, LOW);
       // Move servos between the two positions repeatedly
       initialMoveDone = false;
       PotentiometerMode =false;
      moveServosBetweenPositions(servo01SP[0],servo01SP[1],servo02SP[0],servo02SP[1],servo03SP[0],servo03SP[1],servo04SP[0],servo04SP[1],servo05SP[0],servo05SP[1],servo06SP[0],servo06SP[1]);
      // Check for stop command
      if (Bluetooth.available() > 0 && Bluetooth.read() == 'S' || digitalRead(stopButton) == HIGH) {
        button2Pressed = false;
        PotentiometerMode =true;
        Bluetooth.println("Playback Stopped");
        lcd.clear();
        lcd.setCursor(8, 0);
        lcd.print("NCTU");
        lcd.setCursor(3, 1);
        lcd.print("ICT department");
        lcd.setCursor(3, 2);
        lcd.print("RoboArm control");
        lcd.setCursor(0, 3);
        lcd.print("Playback Stopped");
      }
      delay(500);  // Optional delay between servo movements
    }
  }    
  }
  }


  // Functio to play the move 1
  if (move1Pressed) {
    // Motor control logic
  if (!startSensorState || !stopSensorState || startSensorState || stopSensorState) {
    // Start sensor is HIGH
    if(!startSensorState && stopSensorState)
    {
      digitalWrite(motorPin1, HIGH); // Set motor direction forward
      digitalWrite(motorPin2, LOW); 
    }
    else if (!startSensorState && !stopSensorState || startSensorState && !stopSensorState){
      digitalWrite(motorPin1, LOW); // Set motor direction forward
      digitalWrite(motorPin2, LOW);
       initialMoveDone = false;
       PotentiometerMode =false;
      moveServosBetweenPositions(servo01M1[0],servo01M1[1],servo02M1[0],servo02M1[1],servo03M1[0],servo03M1[1],servo04M1[0],servo04M1[1],servo05M1[0],servo05M1[1],servo06M1[0],servo06M1[1]);
      // Check for stop command
      if (Bluetooth.available() > 0 && Bluetooth.read() == 'S' || digitalRead(stopButton) == HIGH) {
        move1Pressed = false;
        PotentiometerMode =true;
        Bluetooth.println("Playback Stopped");
        lcd.clear();
        lcd.setCursor(8, 0);
        lcd.print("NCTU");
        lcd.setCursor(3, 1);
        lcd.print("ICT department");
        lcd.setCursor(3, 2);
        lcd.print("RoboArm control");
        lcd.setCursor(0, 3);
        lcd.print("Playback Stopped");
      }

      delay(500);  // Optional delay between servo movements
    

    }
  }
  }

  // Functio to play the move 2
  if (move2Pressed) {
    // Motor control logic
  if (!startSensorState || !stopSensorState || startSensorState || stopSensorState) {
    // Start sensor is HIGH
    if(!startSensorState && stopSensorState)
    {
      digitalWrite(motorPin1, HIGH); // Set motor direction forward
      digitalWrite(motorPin2, LOW); 
    }
    else if (!startSensorState && !stopSensorState || startSensorState && !stopSensorState){
      digitalWrite(motorPin1, LOW); // Set motor direction forward
      digitalWrite(motorPin2, LOW);

      while (move2Pressed) {
      moveServosBetweenPositions(servo01SP[0],servo01SP[1],servo02SP[0],servo02SP[1],servo03SP[0],servo03SP[1],servo04SP[0],servo04SP[1],servo05SP[0],servo05SP[1],servo06SP[0],servo06SP[1]);
      // Check for stop command
      if (Bluetooth.available() > 0 && Bluetooth.read() == 'S' || digitalRead(stopButton) == HIGH) {
        move2Pressed = false;
        PotentiometerMode =true;
        Bluetooth.println("Playback Stopped");
        lcd.clear();
        lcd.setCursor(8, 0);
        lcd.print("NCTU");
        lcd.setCursor(3, 1);
        lcd.print("ICT department");
        lcd.setCursor(3, 2);
        lcd.print("RoboArm control");
        lcd.setCursor(0, 3);
        lcd.print("Playback Stopped");
      }

      delay(500);  // Optional delay between servo movements
    }
      
    }
  }
  }
  delay(100);
}