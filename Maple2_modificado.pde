import processing.serial.*;

Serial myPort;
float[] distances = new float[181];

int maxDistance = 250; 
int cx, cy; 

float currentDistance = 0;
int currentAngle = 0;


void setup() {
  size(800, 600); 
  smooth();
  
  cx = width/2;
  cy = height - 50; 
  
  for (int i = 0; i <= 180; i++) distances[i] = -1;


  printArray(Serial.list());
  try {
    String portName = Serial.list()[4]; 
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil('.');
  } catch (Exception e) {
    println("Serial Port invalido");
  }
  
  background(0);
}

void draw() {
  fill(0, 0, 0, 20); 
  noStroke();
  rect(0, 0, width, height);
  
  translate(cx, cy); 
  
  drawRadarGrid();
  
  drawObjects();
  
  drawScanner();
  
  drawTextInfo();
}

void drawRadarGrid() {
  stroke(0, 255, 0, 50); 
  strokeWeight(1);
  noFill();
  
  for (int r = 50; r <= maxDistance*2; r += 100) {
    arc(0, 0, r, r, PI, TWO_PI); 
  }
  
  for (int a = 0; a <= 180; a += 30) {
    float rad = radians(a + 180); 
    float x = (maxDistance + 20) * cos(rad);
    float y = (maxDistance + 20) * sin(rad);
    line(0, 0, x, y);
  }
}

void drawObjects() {
  noStroke();
  
  for (int i = 0; i < 180; i++) {
    if (distances[i] > 0) {
        float rad = radians(i + 180); 
        float distPx = distances[i];
        
        float x = distPx * cos(rad);
        float y = distPx * sin(rad);
        
        fill(0, 255, 0);
        ellipse(x, y, 10, 10);
    }
  }
}

void drawScanner() {
  pushMatrix();
  float rad = radians(currentAngle + 180);
  
  stroke(0, 255, 0);
  strokeWeight(3);
  line(0, 0, maxDistance * cos(rad), maxDistance * sin(rad));
  popMatrix();
}

void drawTextInfo() {
  fill(0, 255, 0);
  textSize(20);
  textAlign(LEFT);
  
  text("Ángulo: " + currentAngle + "°", -cx + 20, -cy + 30);
  
  String distStr = (distances[currentAngle] > 0) ? nf(distances[currentAngle]/10.0, 0, 1) + " cm" : "Fuera de Rango";
  text("Distancia: " + distStr, -cx + 20, -cy + 55);
}

void serialEvent(Serial p) {
  try {
    String line = p.readStringUntil('.');
    if (line != null) {
      line = trim(line);
      String[] parts = split(line, ',');
      
      if (parts.length == 2) {
        int ang = int(parts[0]);
        float dist = float(parts[1]); 
        
        float distPixel = dist * 5; 
        
        if (distPixel > maxDistance) distPixel = -1; 
        if (distPixel < 5) distPixel = -1; 
        
        ang = constrain(ang, 0, 180);
       
        distances[ang] = distPixel;
        currentAngle = ang;
      }
    }
  } catch(RuntimeException e) {
    e.printStackTrace();
  }
}
