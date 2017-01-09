color bgColor;

Insane[] insane;
int numOfInsane;

Sane[] sane;
int numOfSane;


void setup() {
  size(700, 480);

  bgColor = color(242, 242, 237);
  background(bgColor);
  smooth();
  noStroke();


  numOfInsane = 10;
  insane = new Insane[numOfInsane];

  for (int i = 0; i < numOfInsane; i++) {
    insane[i] = new Insane(new PVector(random(0, width), random(0, height)), new PVector(.04, .04));
  }

  numOfSane = 8;
  sane = new Sane[numOfSane];
  sane[0] = new Sane(225, 10.0, 150.0, width/2.0, height/4.0 - 30, color(30, 62, 29));
  sane[1] = new Sane(160, 10.0, 150.0, width/2.0 - 70, height/4.0 + 40, color(201, 209, 105));
  sane[2] = new Sane(175, 10.0, 150.0, width/2.0 - 50, height/4.0 + 20, color(30, 62, 29));
  sane[3] = new Sane(150, 10.0, 150.0, width/2.0 - 20, height/4.0 + 45, color(123, 160, 60));
  sane[4] = new Sane(165, 10.0, 150.0, width/2.0 + 70, height/4.0 + 33, color(123, 160, 60));
  sane[5] = new Sane(200, 10.0, 150.0, width/2.0 + 50, height/4.0, color(30, 62, 29));
  sane[6] = new Sane(175, 10.0, 150.0, width/2.0 + 20, height/4.0 + 20, color(201, 209, 105));
  sane[7] = new Sane(125, 10.0, 150.0, width/2.0 + 40, height/4.0 + 75, color(123, 160, 60));
}

void draw() {


  fill(bgColor);
  rect(0, 0, width, height);

  fill(212, 212, 207);

  fill(77, 73, 41);
  for (int i = 0; i < numOfInsane; i++) {
    insane[i].update();
  }

  for (int i = 0; i < numOfSane; i++) {
    sane[i].calcWave();
    sane[i].renderWave();
  }

  fill(185, 181, 178);
  ellipse(width/2.0, 320, 250, 10);

  for (int i = 0; i < numOfInsane; i++) {
    for (int s = 0; s < numOfSane; s++) {
      if (rectRectIntersect(insane[i].pos.x - (insane[i].w)/2, insane[i].pos.y - (insane[i].h)/2, insane[i].pos.x + (insane[i].w)/2, insane[i].pos.y + (insane[i].h)/2, 
      sane[s].displayW, sane[s].displayH, sane[s].displayW + sane[s].amplitude, sane[s].displayH + sane[s].h)) {
        sane[s].theta += 1.0;
        insane[i].speed.x = 1.0;
        insane[i].speed.y = 1.0;
      }
    }
  }
}


boolean rectRectIntersect(float left, float top, float right, float bottom, 
float otherLeft, float otherTop, float otherRight, float otherBottom) {
  return !(left > otherRight || right < otherLeft || top > otherBottom || bottom < otherTop);
}

class Insane{
  
  PVector pos;
  PVector speed;
  float accel;
  int angle;
  int w, h;
  
  Insane(PVector pos, PVector speed){
    this.pos = pos;
    this.speed = speed;
    this.accel = accel;
    
    w = 10;
    h = 10;
    angle = 0;
  }

  void update(){
    
    angle++;
    if(angle > 360) angle = 0;
    
    accel = 0.5 * cos(radians(angle));
    
    speed.x += accel;
    speed.y += accel;
    pos.x += speed.x;
    pos.y += speed.y;

    
    ellipse(pos.x, pos.y, w, h);
    
    if((width < pos.x) || (pos.x < 0)){
      speed.x *= -1;
    }
    
    if((height < pos.y) || (pos.y < 0)){
      speed.y *= -1;
    }
  }


}
class Sane {


  int yspacing = 3;   // How far apart should each vertical location be spaced
  int h;              // Height of entire wave

  float theta = 0.0;  // Start angle at 0
  float amplitude = 10.0;  // Height of wave
  float period = 150.0;  // How many pixels before the wave repeats
  float dy;  // Value for incrementing Y, a function of period and yspacing
  float[] xvalues;  // Using an array to store width values for the wave

  float displayH;
  float displayW;
  
  color saneColor; 
  
  Sane(int h, float amplitude, float period, float displayW, float displayH, color saneColor) {
    this.h = h;
    this.amplitude = amplitude;
    this.period = period;
    this.displayW = displayW;
    this.displayH = displayH;
    this.saneColor = saneColor;

    yspacing = 3;
    theta = 0.0;
    dy = (TWO_PI / period) * yspacing;
    xvalues = new float[h/yspacing];
  }

  void calcWave() {
    // Increment theta (try different values for 'angular velocity' here
    theta += 0.085;

    // For every x value, calculate a y value with sine function
    float y = theta;
    for (int i = 0; i < xvalues.length; i++) {
      xvalues[i] = sin(y)*amplitude;
      y+=dy;
    }
  }

  void renderWave() {
    // A simple way to draw the wave with an ellipse at each location
    for (int y = 0; y < xvalues.length; y++) {
      fill(saneColor);
      ellipse(displayW + xvalues[y], displayH + y*yspacing, sin(radians(map(y, 0, xvalues.length, 0, 90)))*10, 16);
    }
  }
}


