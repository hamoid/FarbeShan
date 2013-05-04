import oscP5.*;
import netP5.*;
import processing.video.*;
Movie mov;
int x;
int lastMove = 0; 
float videoPos;
int MAX_CURVES = 50;
int lastCurve = 0;
int tickMs = 125;
int lastTick = -1;
FSCurve[] myCurve = new FSCurve[MAX_CURVES];
OscP5 oscP5;
NetAddress toSendto;
NetAddress toReceive;
float fadeOutState = 1;
boolean fadeOut = false;

void setup() {
  oscP5 = new OscP5(this, 8888);
  toSendto = new NetAddress("127.0.0.1", 57120); //send to sclang
  size(640, 360);
  background(0);
  frameRate(30);
  text("LOADING... ", width-150, height-150);
  mov = new Movie(this, "/home/funpro/Desktop/rh/episode 3/rh.avi");
  mov.frameRate(3);
  mov.loop();
  noStroke();
  for (int i=0; i<MAX_CURVES; i++) {
    myCurve[i] = new FSCurve();
  }
}
void draw() {
  mov.loadPixels();
  if (mov.pixels.length > 0) {
    drawBackground1();
  }
  for (int i=0; i<MAX_CURVES; i++) {
    myCurve[i].draw();
  }
  if (int(millis() / tickMs) != lastTick) {
    lastTick = millis() / tickMs;
    sendData();
  }
  if(fadeOut) {
    fadeOutState -= 0.01;
  }
}

void movieEvent(Movie mv) {
  mov.read();
}

void mousePressed() {
  myCurve[lastCurve].init();
}
void mouseReleased() {
  lastCurve = (lastCurve + 1) % MAX_CURVES;
}
void mouseDragged() {
  myCurve[lastCurve].addPoint();
}
void drawBackground1() {
  background(0);
  for (int i=0; i<400 * fadeOutState; i++) {
    int x = int(random(width));
    int y = int(random(height));
    int p = x+y*width;
    float r = random(10, 50);
    fill(mov.pixels[p], 10);
    ellipse(x, y, r, r);
  }
}
void drawBackground2() {
  background(0);
  for (int x=20; x<width; x+=40) {
    for (int y=20; y<height; y+=40) { 
      int p = x+y*width;
      float r = random(10, 50);
      fill(mov.pixels[p], 10);
      ellipse(x, y, r, r);
    }
  }
}
void drawBackground3() {
  image(mov, 0, 0);
  fill(0, 150);
  rect(0, 0, width, height);
}
void sendData() {
  for (int i=0; i<MAX_CURVES; i++) {
    int c = myCurve[i].getCurrColor();
    if (c != 0) {
      OscMessage myMessage = new OscMessage("/FS");
      myMessage.add(i);
      myMessage.add(int(hue(c))); 
      myMessage.add(int(saturation(c))); 
      myMessage.add(int(brightness(c))); 
      myMessage.add(int(alpha(c))); 
      oscP5.send(myMessage, toSendto);
    }
  }
}
void keyPressed() {
  fadeOut = true;
}
