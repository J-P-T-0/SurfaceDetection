import processing.serial.*;

Serial myPort;
float[] distances = new float[180];

float interpSteps = 20; 

float angle = 0;
float distance = 0;
int currentAngle = 0;

void setup() {
  size(600, 600);
  background(0);
  
  // Inicializar con -1 para indicar "sin dato"
  for (int i = 0; i < 180; i++) distances[i] = -1;


  // Selecciona el puerto correcto
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[4], 9600);


  translate(width/2, height/2);
}

boolean angleInRange(int ang, int start, int end) {
  if (start <= end) {
    return ang >= start && ang <= end;
  } else {
    // Maneja wrap-around (ej: 350 → 10)
    return ang >= start || ang <= end;
  }
}


void draw() {
  background(0);
  translate(width/2, height/2);
  stroke(255);
  noFill();
  
  // Dibujar círculos de referencia
  for (int r = 50; r <= 250; r += 50) {
    ellipse(0, 0, r*2, r*2);
  }
  
  int startAngle = max(0, currentAngle - 30);
  int endAngle = currentAngle;
  
  fill(0,255,0);
  noStroke();
  
  for (int ang = 0; ang < 180; ang++) {
    if (distances[ang] >= 0 && angleInRange(ang, startAngle, endAngle)) {
  
      float rad = radians(ang);
      float x = distances[ang] * cos(rad);
      float y = distances[ang] * sin(rad);
  
      ellipse(x, y, 6, 6);
    }
  }
  stroke(0,255,150);
  noFill();
  //beginShape();

  for (int ang = constrain(currentAngle - 20, 0, 179); ang < 180; ang++) {
    if (distances[ang] >= 0) {
      
      float d1 = distances[ang];
      float d2 = distances[ang + 1];

      // Si el siguiente ángulo también tiene dato, interpolar
      if (d2 >= 0) {
        for (int s = 0; s <= interpSteps; s++) {
          float t = s / interpSteps; // 0 → 1
          float dInterp = lerp(d1, d2, t);
          float rad = radians(ang + t);

          float x = dInterp * cos(rad);
          float y = dInterp * sin(rad);
          vertex(x, y);
        }
      } else {
        // sin interpolación
        float rad = radians(ang);
        float x = d1 * cos(rad);
        float y = d1 * sin(rad);
        vertex(x, y);
      }
    }
  }

  //endShape(CLOSE);


  // Dibujar línea desde el centro
  stroke(255,200,0);
  strokeWeight(2);
  float rad = radians(currentAngle);
      
  float x = 280 * cos(rad);
  float y = 280 * sin(rad);

  line(0,0,x,y);
}



void serialEvent(Serial p) {
  String line = p.readStringUntil('.');
  if (line != null) {
    line = trim(line);
    String[] parts = split(line, ',');

    if (parts.length == 2) {
      int ang = int(parts[0]) % 180;
      float dist = float(parts[1])*10;

      if(dist > 250) dist = -1;
      // Guardar la distancia del ángulo
      distances[ang] = dist;
      
      currentAngle = ang;
    }
  }
}
