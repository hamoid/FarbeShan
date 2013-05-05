// Farbe_Shan - Processing code
// https://github.com/hamoid/FarbeShan

// Works together with the FarbeShan SuperCollider code
// to generate sound based on curves the user draws
// on top of a playing video.

// This main program creates an array of blank curves.
// When the user clicks and drags, curves are drawn.
// Curves have a lifespan. After a while, they disappear
// While they exist, they change and they send data
// via OSC to SuperCollider, which plays sounds for those
// curves, depending on the characteristics of the pixels
// in the video under the curve.

// NOTE: In Ubuntu, if using Jack, the loaded video should not
// contain sound. Otherwise the video will be paused.
// You can strip audio using ffmpeg:
// ffmpeg -i source.mp4 -an out.mp4

// Missing: a way to control the video. Maybe it's better to
// stay at one frame (to play it for a while) and then be
// able to jump to next or previous frames.

import oscP5.*;
import netP5.*;
import processing.video.*;

String DEFAULT_MOVIE_PATH = "/home/funpro/Desktop/o2.mp4";

int MAX_CURVES = 50;
FSCurve[] curves = new FSCurve[MAX_CURVES];

int nextCurveID = 0;
int metronomeMs = 125;
int metronomeTickCount = -1;

Movie mov;

OscP5 osc;
NetAddress scLangAddr;

float fadeOutOpacity = 1;
boolean fadeOutActive = false;

void setup() {
  size(640, 360);
  background(0);
  frameRate(30);
  noStroke();
  
  osc = new OscP5(this, 8888);
  scLangAddr = new NetAddress("127.0.0.1", 57120);
  
  text("LOADING... ", width-150, height-150);
  
  selectInput("Select a movie to play", "loadMovie");
    
  for (int i=0; i<MAX_CURVES; i++) {
    curves[i] = new FSCurve();
  }
}
void loadMovie(File path) {
  if(path == null) {
    mov = new Movie(this, DEFAULT_MOVIE_PATH);
  } else {
    mov = new Movie(this, path.getAbsolutePath());
  }
  mov.loop();
  mov.speed(0.05);
  mov.volume(0);
}
void draw() {
  if(mov != null) {
    mov.loadPixels();
      drawBackground3();
    for (int i=0; i<MAX_CURVES; i++) {
      curves[i].draw();
    }
    if (int(millis() / metronomeMs) != metronomeTickCount) {
      metronomeTickCount = millis() / metronomeMs;
      talkToSC();
    }
    if(fadeOutActive) {
      fadeOutOpacity -= 0.01;
    }
  }
}
void movieEvent(Movie mv) {
  mov.read();
}
void mousePressed() {
  curves[nextCurveID].init();
}
void mouseReleased() {
  nextCurveID = (nextCurveID + 1) % MAX_CURVES;
}
void mouseDragged() {
  curves[nextCurveID].addPoint();
}
void drawBackground1() {
  background(0);
  for (int i=0; i<400 * fadeOutOpacity; i++) {
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
void talkToSC() {
  for (int i=0; i<MAX_CURVES; i++) {
    int c = curves[i].getCurrColor();
    // Play notes half of the time.
    // Maybe it's better to send them always
    // and let SC decide when to play.
    // In any case it's better not to play all nates,
    // to allow rythms and silence to exist.
    if (c != 0 && random(1) > 0.5) {
      OscMessage msg = new OscMessage("/FS");
      msg.add(i);
      msg.add(int(hue(c))); 
      msg.add(int(saturation(c))); 
      msg.add(int(brightness(c))); 
      msg.add(int(alpha(c))); 
      osc.send(msg, scLangAddr);
    }
  }
}
void keyPressed() {
  if(key == 'e') {
    fadeOutActive = true;
  }
}
