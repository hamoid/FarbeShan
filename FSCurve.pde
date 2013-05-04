class FSCurve {
  int MAX_POINTS = 100;

  PVector[] points = new PVector[MAX_POINTS];
  int lastPointId = 0;
  int born;
  int maxAge;
  int currStep;
  int totalStep;
  float decay = 1;
  float rate;


  FSCurve() {
  }
  void init() {
    this.born = millis();
    this.maxAge = int(this.born + 1000.0 * random(4, 15));
    this.addPoint();
    this.currStep = 0;
    this.totalStep = int (random(3, 8));
    this.rate = random(30, 60);
  }

  color getCurrColor() {
    if (this.lastPointId > 0) {
      float pc = float(this.currStep) / float(this.totalStep);
      PVector chosen = points[int(pc * lastPointId)];
      int x = int (chosen.x);
      int y = int (chosen.y);      
      this.currStep = (this.currStep + 1) % this.totalStep;
      return getPixelColor(x, y);
    } 
    else {
      return color(0, 0);
    }
  }
  color getPixelColor(int x, int y) {
    x = constrain(x, 0, width-1);
    y = constrain(y, 0, height-1);
    int p = x+y*width;
    int c = mov.pixels[p];
    return color(red(c), green(c), blue(c), 255 * this.decay);
  }

  void doAddPoint() {
    this.points[this.lastPointId] = new PVector(mouseX, mouseY);
    this.lastPointId++;
  }

  void addPoint() {
    if (this.lastPointId == 0) {
      doAddPoint();
    } 
    else {
      PVector curr = new PVector(mouseX, mouseY);
      float d = curr.dist(this.points[this.lastPointId-1]);

      if (d > 5) {
        if (this.lastPointId < MAX_POINTS) {
          doAddPoint();
        }
      }
    }
  }
  void draw() {
    if (this.lastPointId > 0 && mov.pixels.length > 0) {
      float baseRad = 2 + (millis() - this.born) / 1000.0;
      for (int i=0; i<this.lastPointId; i++) {
        float radius = 4 * i/this.lastPointId + baseRad;
        for (int j=0; j<10; j++) {
          int x = int (this.points[i].x+random(-radius, radius));
          int y = int (this.points[i].y+random(-radius, radius));
          fill(getPixelColor(x, y));
          ellipse(x, y, radius, radius);
        }
      }
      if (millis() > this.maxAge) {
        this.decay -= 0.01;
        if (this.decay < 0) {
          this.lastPointId = 0;
        }
      }
    }
  }
}

