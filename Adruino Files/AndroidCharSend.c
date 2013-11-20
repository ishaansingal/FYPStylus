int incomingByte;

void setup() {
  pinMode(53, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  // see if there's incoming serial data:
  if (Serial.available() > 0) {
    // read the oldest byte in the serial buffer:
    incomingByte = Serial.read();
    // if it's a capital R, reset the counter
    if (incomingByte == 'g') {
      digitalWrite(53, HIGH);
      delay(500);
      digitalWrite(53, LOW);
      delay(500);
      //Serial.println("RESET");
      //counter=0;
    }
  }

  //Serial.println(counter);
  //counter++;

  //delay(250);
}