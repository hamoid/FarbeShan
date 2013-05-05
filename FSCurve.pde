class FSCurve {
  int MAX_POINTS = 100;

  PVector[] points = new PVector[MAX_POINTS];
  PVector lastPlayedPoint;
  
  int lastPointId = 0;
  int bornMs;
  int maxAgeMs;
  int currStep;
  int totalStep;
  float decay = 1;
  float rate;

  FSCurve() {
  }
  
  void init() {
    this.bornMs = millis();
    this.maxAgeMs = int(this.bornMs + 1000.0 * random(4, 15));
    this.addPoint();
    this.currStep = 0;
    this.totalStep = int (random(3, 8));
    this.decay = 1;
    this.rate = random(30, 60);
    lastPlayedPoint = new PVector(-10, -10);
  }

  public color getCurrColor() {
    if (this.lastPointId > 0) {
      float pc = float(this.currStep) / float(this.totalStep);
      lastPlayedPoint = points[int(pc * lastPointId)];
      this.currStep = (this.currStep + 1) % this.totalStep;
      return getPixelColor((int)lastPlayedPoint.x, (int)lastPlayedPoint.y);
    } 
    else {
      return color(0, 0);
    }
  }
  private color getPixelColor(int x, int y) {
    x = constrain(x, 0, width-1);
    y = constrain(y, 0, height-1);
    int p = x+y*width;
    int c = mov.pixels[p];
    return color(red(c), green(c), blue(c), 255 * this.decay);
  }

  private void doAddPoint() {
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
      float baseRad = 2 + (millis() - this.bornMs) / 1000.0;
      for (int i=0; i<this.lastPointId; i++) {
        float radius = 4 * i/this.lastPointId + baseRad;
        for (int j=0; j<10; j++) {
          int x = int (this.points[i].x+random(-radius, radius));
          int y = int (this.points[i].y+random(-radius, radius));
          fill(getPixelColor(x, y));
          ellipse(x, y, radius, radius);
        }
      }
      if (millis() > this.maxAgeMs) {
        this.decay -= 0.01;
        if (this.decay < 0) {
          this.lastPointId = 0;
        }
      }
      fill(255, 100);
      ellipse(lastPlayedPoint.x, lastPlayedPoint.y, 20, 20);
    }
  }
}

