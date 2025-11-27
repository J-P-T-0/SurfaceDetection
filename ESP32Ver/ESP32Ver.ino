// Cargar la librería Servo
#include <ESP32Servo.h> 
// Definir pines Trig y Echo del sensor
const int trigPin = 4;
const int echoPin = 2;
const int servoPin = 12;

long duration;
int distance;
Servo myServo; 
void setup() {
  pinMode(trigPin, OUTPUT); 
  pinMode(echoPin, INPUT);
  Serial.begin(9600);
  myServo.attach(servoPin); 
}

void loop() {
  // rota el servo motor desde 10 hasta 170 grados
  for(int i=10; i<=170; i+=1){  
     myServo.write(i);
     delay(35);
     distance = calculateDistance();
  
     Serial.print(i); // Envía los grados a la GUI
     Serial.print(","); 
     Serial.print(distance); // Envia la información de distancia a la GUI
     Serial.print("."); 
  }
  // Regresar de 170 a 10 grados
  for(int i=170; i>10; i-=1){  
     myServo.write(i);
     delay(35);
     distance = calculateDistance();
  
     Serial.print(i);
     Serial.print(",");
     Serial.print(distance);
     Serial.print(".");
  }
}


// Función para calcular la distancia usando el sensor ultrsonico

int calculateDistance(){ 
  
  digitalWrite(trigPin, LOW); 
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH); 
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH); //Lectura del echoPin, regresa la onda de sonido
  distance = duration*0.034/2;
  return distance;
}
