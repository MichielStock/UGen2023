//
// Adapted from @marcedwards' splitlines:
// https://twitter.com/marcedwards/status/1212718884224040965
// https://gist.github.com/marcedwards/d9ad996998a79b3f970632fc8b497816 
//

PImage maskA;
PImage maskB;
PImage bufferA;
PImage bufferB;
PImage img;
float frameseed = timeNoise(8 * 20, 20, 8);

void setup() {
  size(450, 600, P2D);
  img = loadImage("deco.png");
  frameRate(30);
  smooth(8);
  noiseDetail(5, 0.8);
  background(0);
  img.resize(width, height);
  image(img, 0., 0.);
  maskA = createImage(width, height, RGB);
  maskB = createImage(width, height, RGB);
  bufferA = createImage(width, height, ARGB);
  bufferB = createImage(width, height, ARGB);
  bufferA.copy(img, 0, 0, width, height, 0, 0, width, height);
  bufferB.copy(img, 0, 0, width, height, 0, 0, width, height);
}

void draw() {
  int framestep = 10;
  int totalframes = framestep * 20;
  float frame = frameCount % framestep;
  float r = 4 + 48*noise(frameseed);
  float anim = Ease.hermite5(frame / framestep) * r;
  float dx = cos(2*frameseed * TAU - HALF_PI) * anim;
  float dy = sin(2*frameseed * TAU - HALF_PI) * anim;

  if (frame == 0) {
    frameseed = timeNoise(totalframes, 20, 8);
    drawMasks(frameseed);
  }

  background(img);
  bufferA.mask(maskA);
  image(bufferA, -dx, -dy);
  bufferB.mask(maskB);
  image(bufferB, dx, dy);

  //renderRange(totalframes * 8, totalframes);
}

void drawMasks(float seed) {
  bufferA.copy(g, 0, 0, width, height, 0, 0, width, height);

  background(0);
  fill(255);
  noStroke();
  drawLine(seed);
  maskA.copy(g, 0, 0, width, height, 0, 0, width, height);
  filter(INVERT);
  maskB.copy(g, 0, 0, width, height, 0, 0, width, height);

  image(bufferA, 0, 0);
  noFill();
  // blendMode(EXCLUSION);
  stroke(255);
  strokeWeight(3);
  drawLine(seed);
  bufferA.copy(g, 0, 0, width, height, 0, 0, width, height);
  bufferB.copy(bufferA, 0, 0, width, height, 0, 0, width, height);
}

void drawLine(float seed) {
  float rad = max(width, height) * sqrt(2); 

  pushMatrix();
  translate(width / 2, height / 2);
  translate(cos(seed * 60 - seed) * 100, sin(seed * 60 - seed) * 100); 
  rotate(2*seed * TAU);
  
  beginShape();
  vertex(0., 0.);
  vertex(0.65*rad*abs(noise(seed)), 0.6*rad);
  vertex(-0.65*rad*abs(noise(2*seed)), 0.6*rad);
  endShape(CLOSE);

  popMatrix();
}

//

float timeLoop(float totalframes, float offset) {
  return (frameCount + offset) % totalframes / totalframes;
}

float timeLoop(float totalframes) {
  return timeLoop(totalframes, 0);
}

float timeNoise(float totalframes, float diameter, float zoffset) {
   return noise(cos(timeLoop(totalframes) * TAU) * diameter + diameter,
                sin(timeLoop(totalframes) * TAU) * diameter + diameter,
                zoffset);
}

float timeNoise(float totalframes, float diameter) {
  return timeNoise(totalframes, diameter, 0);
}

float timeNoise(float totalframes) {
  return timeNoise(totalframes, 0.01, 0);
}

static class Ease {
  static public float hermite5(float t) {
    return t * t * t * (t * (t * 6 - 15) + 10);
  }

  static public float hermite5(float t, int repeat) {
    for (int i = 0; i < repeat; i++) {
      t = hermite5(t);
    }
    return t;
  }
}