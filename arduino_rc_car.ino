
#define LEFT_MOTOR_POWER_PIN 3
#define LEFT_MOTOR_FWD_PIN 4
#define LEFT_MOTOR_BWD_PIN 5

#define RIGHT_MOTOR_POWER_PIN 9
#define RIGHT_MOTOR_FWD_PIN 11
#define RIGHT_MOTOR_BWD_PIN 10

#define MOTOR_FULL 255
#define MOTOR_ON 125
#define MOTOR_OFF 0

#define DIR_FORWARD 49
#define DIR_BACKWARD 50
#define DIR_FORWARD_RIGHT 51
#define DIR_FORWARD_LEFT 52
#define DIR_BACKWARD_RIGHT 53
#define DIR_BACKWARD_LEFT 54

void setLeftMotorDirection(char dir) {
  if(dir > 0) {
    digitalWrite(LEFT_MOTOR_FWD_PIN, HIGH);
    digitalWrite(LEFT_MOTOR_BWD_PIN, LOW);
    analogWrite(LEFT_MOTOR_POWER_PIN, MOTOR_ON);
  }
  else if(dir < 0) {
    digitalWrite(LEFT_MOTOR_FWD_PIN, LOW);
    digitalWrite(LEFT_MOTOR_BWD_PIN, HIGH);
    analogWrite(LEFT_MOTOR_POWER_PIN, MOTOR_ON);
  }
  else {
    digitalWrite(LEFT_MOTOR_FWD_PIN, LOW);
    digitalWrite(LEFT_MOTOR_BWD_PIN, LOW);
    analogWrite(LEFT_MOTOR_POWER_PIN, MOTOR_OFF);
  }
}

void setRightMotorDirection(char dir) {
  if(dir > 0) {
    digitalWrite(RIGHT_MOTOR_FWD_PIN, HIGH);
    digitalWrite(RIGHT_MOTOR_BWD_PIN, LOW);
    analogWrite(RIGHT_MOTOR_POWER_PIN, MOTOR_ON);
  }
  else if(dir < 0) {
    digitalWrite(RIGHT_MOTOR_FWD_PIN, LOW);
    digitalWrite(RIGHT_MOTOR_BWD_PIN, HIGH);
    analogWrite(RIGHT_MOTOR_POWER_PIN, MOTOR_ON);
  }
  else {
    digitalWrite(RIGHT_MOTOR_FWD_PIN, LOW);
    digitalWrite(RIGHT_MOTOR_BWD_PIN, LOW);
    analogWrite(RIGHT_MOTOR_POWER_PIN, MOTOR_OFF);
  }
}

void setup() {
  Serial.begin(9600);

  pinMode(LEFT_MOTOR_POWER_PIN, OUTPUT);
  pinMode(LEFT_MOTOR_FWD_PIN, OUTPUT);
  pinMode(LEFT_MOTOR_BWD_PIN, OUTPUT);
  pinMode(RIGHT_MOTOR_POWER_PIN, OUTPUT);
  pinMode(RIGHT_MOTOR_FWD_PIN, OUTPUT);
  pinMode(RIGHT_MOTOR_BWD_PIN, OUTPUT);

  analogWrite(LEFT_MOTOR_POWER_PIN, MOTOR_OFF);
  analogWrite(RIGHT_MOTOR_POWER_PIN, MOTOR_OFF);
}

void loop() {
  if(Serial.available() > 0) {
    const unsigned char data = Serial.read();
    Serial.write(data);

    switch(data) {
      case DIR_FORWARD:
        setLeftMotorDirection(1);
        setRightMotorDirection(1);
        break;
      case DIR_BACKWARD:
        setLeftMotorDirection(-1);
        setRightMotorDirection(-1);
        break;
      case DIR_FORWARD_RIGHT:
        setLeftMotorDirection(1);
        setRightMotorDirection(0);
        break;
      case DIR_FORWARD_LEFT:
        setLeftMotorDirection(0);
        setRightMotorDirection(1);
        break;
        case DIR_BACKWARD_RIGHT:
        setLeftMotorDirection(-1);
        setRightMotorDirection(0);
        break;
      case DIR_BACKWARD_LEFT:
        setLeftMotorDirection(0);
        setRightMotorDirection(-1);
        break;
      default:
        setLeftMotorDirection(0);
        setRightMotorDirection(0);
        break;
    }
  }
}
