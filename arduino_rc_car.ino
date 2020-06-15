
#define LEFT_MOTOR_POWER_PIN 3
#define LEFT_MOTOR_FWD_PIN 4
#define LEFT_MOTOR_BWD_PIN 5

#define RIGHT_MOTOR_POWER_PIN 9
#define RIGHT_MOTOR_FWD_PIN 11
#define RIGHT_MOTOR_BWD_PIN 10

#define MOTOR_ON 255
#define MOTOR_OFF 0

#define DIR_STOP 0
#define DIR_FORWARD 1
#define DIR_BACKWARD -1

unsigned char buffer[3];
unsigned char bufferLen = 0;

void moveLeftMotor(int power) {
  if(power > 0) {
    digitalWrite(LEFT_MOTOR_FWD_PIN, HIGH);
    digitalWrite(LEFT_MOTOR_BWD_PIN, LOW);
    analogWrite(LEFT_MOTOR_POWER_PIN, (char)power);
  }
  else if(power < 0) {
    digitalWrite(LEFT_MOTOR_FWD_PIN, LOW);
    digitalWrite(LEFT_MOTOR_BWD_PIN, HIGH);
    analogWrite(LEFT_MOTOR_POWER_PIN, (char)(-power));
  }
  else {
    digitalWrite(LEFT_MOTOR_FWD_PIN, LOW);
    digitalWrite(LEFT_MOTOR_BWD_PIN, LOW);
    analogWrite(LEFT_MOTOR_POWER_PIN, MOTOR_OFF);
  }
}

void moveRightMotor(int power) {
  if(power > 0) {
    digitalWrite(RIGHT_MOTOR_FWD_PIN, HIGH);
    digitalWrite(RIGHT_MOTOR_BWD_PIN, LOW);
    analogWrite(RIGHT_MOTOR_POWER_PIN, (char)power);
  }
  else if(power < 0) {
    digitalWrite(RIGHT_MOTOR_FWD_PIN, LOW);
    digitalWrite(RIGHT_MOTOR_BWD_PIN, HIGH);
    analogWrite(RIGHT_MOTOR_POWER_PIN, (char)(-power));
  }
  else {
    digitalWrite(RIGHT_MOTOR_FWD_PIN, LOW);
    digitalWrite(RIGHT_MOTOR_BWD_PIN, LOW);
    analogWrite(RIGHT_MOTOR_POWER_PIN, MOTOR_OFF);
  }
}

int lerpPower(int from, int to, float delta) {
  return from + (int)((to - from) * delta);
}

void clearBuffer() {
  bufferLen = 0;
  buffer[0] = buffer[1] = buffer[2] = 0;
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
    buffer[bufferLen++] = Serial.read();
  }
  
  if(bufferLen == 3) {
    int lmPow = MOTOR_OFF, rmPow = MOTOR_OFF;
    
    if(buffer[0]) {
      unsigned int deg = buffer[1] * 256 + buffer[2];
      Serial.print(deg);
      Serial.println(" degrees");

      if(deg >= 0 && deg < 45) {
        lmPow = MOTOR_ON;
        rmPow = lerpPower(MOTOR_ON, MOTOR_OFF, deg / 45.0f);
      }
      else if(deg >= 45 && deg < 90) {
        lmPow = MOTOR_ON;
      }
      else if(deg >= 90 && deg < 135) {
        lmPow = lerpPower(MOTOR_ON, -MOTOR_ON, (deg - 90) / 45.0f);
      }
      else if(deg >= 135 && deg < 180) {
        lmPow = -MOTOR_ON;
        rmPow = lerpPower(MOTOR_OFF, -MOTOR_ON, (deg - 135) / 45.0f);
      }
      else if(deg >= 180 && deg < 225) {
        lmPow = lerpPower(-MOTOR_ON, MOTOR_OFF, (deg - 180) / 45.0f);;
        rmPow = -MOTOR_ON;
      }
      else if(deg >= 225 && deg < 270) {
        rmPow = lerpPower(-MOTOR_ON, MOTOR_ON, (deg - 225) / 45.0f);
      }
      else if(deg >= 270 && deg < 315) {
        rmPow = MOTOR_ON;
      }
      else if(deg >= 315 && deg < 360) {
        lmPow = lerpPower(MOTOR_OFF, MOTOR_ON, (deg - 315) / 45.0f);;
        rmPow = MOTOR_ON;
      }
    }

    moveLeftMotor(lmPow);
    moveRightMotor(rmPow);

    clearBuffer();
  }
}
