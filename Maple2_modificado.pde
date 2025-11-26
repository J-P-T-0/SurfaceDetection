import processing.serial.*; //libreria que permite la comunicación serie entre PC y Arduino
import java.awt.event.KeyEvent;
import java.util.ArrayList;

Serial myPort;  // crea objeto myPort


// Definición de variables
String angle = "";
String distance = "";
String data = "";
int iAngle, iDistance;
int index1 = 0;
PFont font;  //objeto para dar formato de texto
float x, y;  // para convertir distancia y ángulo en coordenadas x, y
float PI = 3.1415;
FloatList s1, s2;
float axisx=100, axisy=150, finale=400;  //dimensiones para el área de graficación
//arreglos de las coordenadas para la línea
ArrayList<Float> xini = new ArrayList<Float>();
ArrayList<Float> yini = new ArrayList<Float>();
ArrayList<Float> xfin = new ArrayList<Float>();
ArrayList<Float> yfin = new ArrayList<Float>();
float escalay=5;
float escalax=0.06;
int numlin=1, index=0;



void setup() {
  
   size (500, 500); // Tamaño de la interfaz en pixeles (Ancho = 500, Alto = 500). Puede cambiar el tamaño
   font = createFont("Arial", 24); // constructr de la instancia font
   //myPort = new Serial(this,"COM3", 9600); // comienza la comunicación serie. Cambiar COM5 a COM-X- de acuerdo al puerto de su Arduino 
   myPort = new Serial(this,"COM4", 9600);
   myPort.bufferUntil('.'); // Lee los datos desde el puerto serial hasta el caracter '. 
   xini.add(axisx);
   yini.add(finale);
}

void draw() {

   background(98,120,31); //Color de fondo de la interfaz en escala (R;G;B). R, G, B pueden tomar valores entre 0 y 255. Si quiere cambiar color, cambie valores.
   text("Contorno de la Superficie", 180, 50); // Escribir texto en la interfaz comenzando en la posición (200, 50)
   fill(255, 255, 255); // Establece el color de relleno (rojo)
   /*strokeWeight(4); 
   rect(100, 150, 300, 300);*/
   datos();
   grafica();  //esta función solo dibuja los ejes del plano cartesiano (quiero ver si luego se le puede poner valores a los ejes)
   graficar();  //esta es la función para la línea (no tiene condición si se excede el eje y)
   index++;
  // DESAFÍO: CREAR UN MÉTODO PARA QUE CON LOS DATOS OBTENIDOS (X, Y) EL PROGRAMA VAYA GRAFICANDO EL CONTORNO Y SE MUESTRE EN LA INTERFAZ. 
  // PONER SU CÓDIGO AQUÍ O CREAR FUNCIÓN ABAJO
}


void serialEvent(Serial myPort) { // comienza la lectura del puerto serie
    data = myPort.readStringUntil('.'); // data lee la información y se detiene hasta que aparece un punto. El formato viene desde el IDE de Arduino.
    data = data.substring(0,data.length()-1); // particionamos data para leer por separado distancia y ángulo.
  
    index1 = data.indexOf(","); //
    angle= data.substring(0, index1); // 
    distance= data.substring(index1+1, data.length()); // 
    iAngle = int(angle); // ángulo del servo.
    iDistance = int(distance); // distancia medida por el sensor ultrasónico.
}

void datos(){
    x = iDistance*cos(PI*iAngle/180);
    y = iDistance*sin(PI*iAngle/180);
    text("          x: " + x + " cm ", 100, 100);
    text("          y: " + y + " cm ", 100, 120);
    if(x<0){  //ángulos mayores de 90 dan cosenos negativos esto es para q no se resten
    x*=-1;
    }
    
    if(y<=10&&numlin==1){
      escalay=4;
    }else if(10<y&&y<=50&&numlin==1){
      escalay=3;
    }else if(50<y&&y<=250&&numlin==1){
      escalay=2;
    }else if(250<y&&y<=400&&numlin==1){
      escalay=0.5;
    }else if(y>400&&numlin==1){
      escalay=0.3;
    }
    
    if(x<=5){
      escalax=0.1;
    }else if(5<x&&x<=10){
      escalax=0.05;
    }else if(10<x&&x<=50){
      escalax=0.01;
    }else if(x>50){
      escalax=0.005;
    }
    text("     Escala y: " + escalay + " :1 ", 200, 100);
    text("     Escala x: " + escalax + " :1 ", 200, 120);
}

void grafica(){
  text("x", finale+10, finale);
  line(axisx,finale,finale,finale);
  text("y", axisx, axisy-10);
  line(axisx,axisy,axisx,finale);
}

void graficar(){
  xfin.add((x*escalax)+xini.get(index));  
  yfin.add(finale-(y*escalay));
  for (int i = 0; i < numlin; i++) {
     line(xini.get(i),yini.get(i),xfin.get(i),yfin.get(i));  //dibuja las líneas
  }
  xini.add(xfin.get(index));
  yini.add(yfin.get(index));
  numlin++;
  if(xfin.get(index)>400||yfin.get(index)<150){  //esto es si excede el límite de x
    numlin=1;
    index=-1;
    xfin.clear();
    yfin.clear();
    xini.clear();
    yini.clear();
    xini.add(axisx);
    yini.add(finale);
  }
}
