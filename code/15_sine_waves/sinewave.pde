int xspacing = 16;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave

float dx;  // Value for incrementing X, a function of period and xspacing


int drop_generation_chance = 30; //chance a new drop will be genarated during a frame. Higher = lower chance
ArrayList<Drop> droplist = new ArrayList<Drop>();
Wave_dot[] wavelist;
int dropsize = 8;

void setup() {
  size(640, 360);
  w = width+16;
  wavelist = new Wave_dot[w/xspacing]; //<>//
  
  dx = (TWO_PI / period) * xspacing;
  for (int i = 0; i < w/xspacing; i++) {
    wavelist[i] = new Wave_dot(i);
  }
  frameRate = 5;
}

void draw() {
  background(0);
  theta += 0.02; 
  for (Wave_dot dot : wavelist){
    dot.update_y();
    dot.render();
  }
/*
  if (random(drop_generation_chance) >= drop_generation_chance-1){
    droplist.add(new Drop());
  }
  for (Drop d : droplist){
   d.update_all_and_render(); 
  }
  /*calculate_colision_impact();
  renderWave();*/
}
/*
void calc_base_wave() {
   Increment theta (try different values for 'angular velocity' here
  theta += 0.02;

   For every x value, calculate a y value with sine function
  float x = theta;
  for (int i = 0; i < y_base_values.length; i++) {
    y_base_values[i] =  height/2 + sin(x)*amplitude;
    x+=dx;
  }
}

void calculate_colision_impact(){
  
  
}

void renderWave() {
  
}

*/
